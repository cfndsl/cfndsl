# frozen_string_literal: true

require 'hana'

module CfnDsl
  # Helper module for bridging the gap between a static types file included in the repo
  # and dynamically generating the types directly from the AWS specification
  # rubocop:disable Metrics/ModuleLength
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
    # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
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
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

    def self.determine_spec_file
      return CfnDsl.specification_file if File.exist? CfnDsl.specification_file

      File.expand_path('aws/resource_specification.json', __dir__)
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def self.extract_from_resource_spec!
      spec_file = JSON.parse File.read(determine_spec_file)
      specs = Dir[File.expand_path('aws/patches/*.spec.json', __dir__)]
      patches = Dir[File.expand_path('aws/patches/*patch.json', __dir__)]
      if specs.length.positive?
        specs.each do |spec|
          spec_file['ResourceTypes'].merge!(JSON.parse(File.read(spec))['ResourceTypes'])
          spec_file['PropertyTypes'].merge!(JSON.parse(File.read(spec))['PropertyTypes'])
        end
      end
      if patches.length.positive?
        patches.each do |patch|
          to_patch = JSON.parse(File.read(patch))
          to_patch.each_key do |type|
            to_patch[type].each_key do |primitive|
              begin
                if primitive == 'patch'
                  jpatch = Hana::Patch.new to_patch[type]['patch']['operations']
                  jpatch.apply(spec_file[type])
                else
                  jpatch = Hana::Patch.new to_patch[type][primitive]['patch']['operations']
                  jpatch.apply(spec_file[type][primitive])
                end
              rescue Hana::Patch::MissingTargetException
                # TODO: Temp fix on 1.0.0-pre
                warn "Ignoring patch exception for #{type} #{primitive} #{patch}"
              end
            end
          end
        end
      end
      resources = extract_resources spec_file['ResourceTypes']
      types = extract_types spec_file['PropertyTypes']
      { 'Resources' => resources, 'Types' => types }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
  # rubocop:enable  Metrics/ModuleLength
end
# rubocop:enable
