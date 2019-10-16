# frozen_string_literal: true

require 'hana'

module CfnDsl
  # Helper module for bridging the gap between a static types file included in the repo
  # and dynamically generating the types directly from the AWS specification
  module Specification
    # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/MethodLength
    def self.extract_resources(spec)
      spec.each_with_object({}) do |(resource_name, resource_info), resources|
        properties = resource_info['Properties'].each_with_object({}) do |(property_name, property_info), extracted|
          # some json incorrectly labelled as Type -> Json instead of PrimitiveType
          # also, AWS now has the concept of Map which cfndsl had never defined
          if property_info['Type'] == 'Map' || property_info['Type'] == 'Json'
            property_type = 'Json'
          elsif property_info['PrimitiveType']
            property_type = property_info['PrimitiveType']
          elsif property_info['PrimitiveItemType']
            property_type = Array(property_info['PrimitiveItemType'])
          elsif property_info['PrimitiveTypes']
            property_type = property_info['PrimitiveTypes'][0]
          elsif property_info['ItemType']
            # Tag is a reused type, but not quite primitive
            # and not all resources use the general form
            property_type = if property_info['ItemType'] == 'Tag'
                              ['Tag']
                            else
                              Array(resource_name.split('::').join + property_info['ItemType'])
                            end
          elsif property_info['Type']
            # Special types (defined below) are joined with their parent
            # resource name for uniqueness and connection
            property_type = resource_name.split('::').join + property_info['Type']
          else
            warn "could not extract resource type from #{resource_name}"
          end
          extracted[property_name] = property_type
          extracted
        end
        resources[resource_name] = { 'Properties' => properties }
        resources
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength
    def self.extract_types(spec)
      primitive_types = {
        'String' => 'String',
        'Boolean' => 'Boolean',
        'Json' => 'Json',
        'S3Event' => 'S3Event',
        'Integer' => 'Integer',
        'Number' => 'Number',
        'Double' => 'Double',
        'Timestamp' => 'Timestamp',
        'Map' => 'Map',
        'Long' => 'Long'
      }
      spec.each_with_object(primitive_types) do |(property_name, property_info), types|
        # In order to name things uniquely and allow for connections
        # we extract the resource name from the property
        # AWS::IAM::User.Policy becomes AWSIAMUserPolicy
        root_resource = property_name.match(/(.*)\./)
        root_resource_name = root_resource ? root_resource[1].gsub(/::/, '') : property_name
        property_name = property_name.gsub(/::|\./, '')

        if property_info.key?('PrimitiveType')
          properties = property_info['PrimitiveType']
        elsif property_info.key?('Type')
          properties = property_info['Type']
        elsif property_info.key?('Properties')
          properties = property_info['Properties'].each_with_object({}) do |(nested_prop_name, nested_prop_info), extracted|
            if nested_prop_info['Type'] == 'Map' || nested_prop_info['Type'] == 'Json'
              # The Map type and the incorrectly labelled Json type
              nested_prop_type = 'Json'
            elsif nested_prop_info['PrimitiveType']
              nested_prop_type = nested_prop_info['PrimitiveType']
            elsif nested_prop_info['PrimitiveItemType']
              nested_prop_type = Array(nested_prop_info['PrimitiveItemType'])
            elsif nested_prop_info['PrimitiveItemTypes']
              nested_prop_type = Array(nested_prop_info['PrimitiveItemTypes'])
            elsif nested_prop_info['Types']
              nested_prop_type = Array(nested_prop_info['Types'])
            elsif nested_prop_info['ItemType']
              # Tag is a reused type, but not quite primitive
              # and not all resources use the general form
              nested_prop_type =
                if nested_prop_info['ItemType'] == 'Tag'
                  ['Tag']
                else
                  Array(root_resource_name + nested_prop_info['ItemType'])
                end

            elsif nested_prop_info['Type']
              nested_prop_type = root_resource_name + nested_prop_info['Type']
            else
              warn "could not extract property type from #{property_name}"
              p nested_prop_info
            end
            extracted[nested_prop_name] = nested_prop_type
            extracted
          end
        end
        types[property_name] = properties
        types
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength

    def self.determine_spec_file
      return CfnDsl.specification_file if File.exist? CfnDsl.specification_file

      LOCAL_SPEC_FILE
    end

    def self.extract_from_resource_spec!(fail_patches: false)
      spec_file = JSON.parse File.read(determine_spec_file)
      patcher = Patcher.new(spec_file, fail_patches: fail_patches)
      specs = Dir[File.expand_path('aws/patches/*.spec.json', __dir__)]
      specs.each { |spec| patcher.merge_spec(JSON.parse(File.read(spec)), spec) }

      # TODO: This does not match all the current patch files, some are patches.json etc..
      patches = Dir[File.expand_path('aws/patches/*patch.json', __dir__)]
      patches.each { |patch| patcher.patch_spec(JSON.parse(File.read(patch)), patch) }

      resources = extract_resources spec_file['ResourceTypes']
      types = extract_types spec_file['PropertyTypes']
      { 'Resources' => resources, 'Types' => types, 'Version' => patcher.version }
    end

    # Applies JSON patches to a specification
    class Patcher
      attr_reader :spec, :fail_patches
      def initialize(spec, fail_patches: false)
        @spec = spec
        @fail_patches = fail_patches
      end

      def version
        @version ||= Gem::Version.new(@spec['ResourceSpecificationVersion'])
      end

      def default_fixed_version
        @default_fixed_version ||= version.bump
      end

      def default_broken_version
        @default_broken_version ||= Gem::Version.new(nil)
      end

      def version_within?(patch)
        broken = patch.key?('broken') ? Gem::Version.new(patch['broken']) : default_broken_version
        fixed = patch.key?('fixed') ? Gem::Version.new(patch['fixed']) : default_fixed_version
        broken <= version && version < fixed
      end

      def merge_spec(spec_parsed, _from_file)
        return unless version_within?(spec_parsed)

        spec['ResourceTypes'].merge!(spec_parsed['ResourceTypes'])
        spec['PropertyTypes'].merge!(spec_parsed['PropertyTypes'])
      end

      def patch_spec(parsed_patch, from_file)
        return unless version_within?(parsed_patch)

        parsed_patch.each_pair do |top_level_type, patches|
          next unless %w[ResourceTypes PropertyTypes].include?(top_level_type)

          patches.each_pair do |property_type_name, patch_details|
            begin
              applies_to = spec[top_level_type]
              unless property_type_name == 'patch'
                # Patch applies within a specific property type
                applies_to = applies_to[property_type_name]
                patch_details = patch_details['patch']
              end

              Hana::Patch.new(patch_details['operations']).apply(applies_to) if version_within?(patch_details)
            rescue Hana::Patch::MissingTargetException => e
              raise "Failed specification patch #{top_level_type} #{property_type_name} from #{from_file}" if fail_patches

              warn "Ignoring failed specification patch #{top_level_type} #{property_type_name} from #{from_file} - #{e.class.name}:#{e.message}"
            end
          end
        end
      end
    end
  end
end
# rubocop:enable
