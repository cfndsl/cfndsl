# frozen_string_literal: true

require 'json'
require 'hana'
require_relative 'globals'

module CfnDsl
  # Module for loading and patching a spec file
  class Specification
    def self.load_file(file: CfnDsl.specification_file, specs: CfnDsl.additional_specs, patches: CfnDsl.specification_patches, fail_patches: false)
      specification = new(file)
      specs&.each { |spec| specification.merge_spec(JSON.parse(File.read(spec)), spec) }
      patches&.each { |patch| specification.patch_spec(JSON.parse(File.read(patch)), patch, fail_patches) }
      specification
    end

    def self.update_required?(version:, file: CfnDsl.specification_file)
      version.to_s == 'latest' || !File.exist?(file) || load_file(file: file, specs: nil, patches: nil).update_required?(version)
    end

    attr_reader :file, :spec

    def initialize(file)
      @file = file
      @spec = JSON.parse File.read(file)
    end

    def resources
      spec['ResourceTypes']
    end

    def types
      spec['PropertyTypes']
    end

    # @return [Gem::Version] semantic version of the spec file
    def version
      @version ||= Gem::Version.new(spec['ResourceSpecificationVersion'] || '0.0.0')
    end

    def default_fixed_version
      @default_fixed_version ||= version.bump
    end

    def default_broken_version
      @default_broken_version ||= Gem::Version.new('0.0.0')
    end

    def update_required?(needed_version)
      needed_version.to_s == 'latest' || version < Gem::Version.new(needed_version || '0.0.0')
    end

    def patch_required?(patch)
      broken = patch.key?('broken') ? Gem::Version.new(patch['broken']) : default_broken_version
      fixed = patch.key?('fixed') ? Gem::Version.new(patch['fixed']) : default_fixed_version
      broken <= version && version < fixed
    end

    def merge_spec(spec_parsed, _from_file)
      return unless patch_required?(spec_parsed)

      spec['ResourceTypes'].merge!(spec_parsed['ResourceTypes'])
      spec['PropertyTypes'].merge!(spec_parsed['PropertyTypes'])
    end

    def patch_spec(parsed_patch, from_file, fail_patches)
      return unless patch_required?(parsed_patch)

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

            Hana::Patch.new(patch_details['operations']).apply(applies_to) if patch_required?(patch_details)
          rescue Hana::Patch::MissingTargetException => e
            raise "Failed specification patch #{top_level_type} #{property_type_name} from #{from_file}" if fail_patches

            warn "Ignoring failed specification patch #{top_level_type} #{property_type_name} from #{from_file} - #{e.class.name}:#{e.message}"
          end
        end
      end
    end
  end
end
# rubocop:enable
