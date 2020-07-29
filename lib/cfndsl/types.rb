# frozen_string_literal: true

require 'yaml'
require_relative 'plurals'
require_relative 'names'
require_relative 'specification'

module CfnDsl
  # Types helper
  # rubocop:disable Metrics/ModuleLength
  module Types
    def self.extract_from_resource_spec(fail_patches: false)
      spec = Specification.load_file(fail_patches: fail_patches)
      resources = extract_resources spec.resources
      types = extract_types spec.types
      { 'Resources' => resources, 'Types' => types, 'Version' => spec.version, 'File' => spec.file }
    end

    # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity
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

    # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/MethodLength
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
    # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity
    def self.included(type_def)
      types_list = extract_from_resource_spec
      type_def.const_set('Types_Internal', types_list)
      # Do a little sanity checking - all of the types referenced in Resources
      # should be represented in Types
      types_list['Resources'].each_key do |resource_name|
        resource = types_list['Resources'][resource_name]
        resource.each_value do |thing|
          thing.each_value do |type|
            if type.is_a?(Array)
              type.each do |inner_type|
                warn "unknown type #{inner_type}" unless types_list['Types'].key?(inner_type)
              end
            else
              warn "unknown type #{type}" unless types_list['Types'].key?(type)
            end
          end
        end
      end

      # All of the type values should also be references
      types_list['Types'].values do |type|
        if type.respond_to?(:values)
          type.each_value do |tv|
            warn "unknown type #{tv}" unless types_list['Types'].key?(tv)
          end
        end
      end

      classes = {}

      # Go through and declare all of the types first
      types_list['Types'].each_key do |typename|
        if !type_def.const_defined?(typename)
          klass = type_def.const_set(typename, Class.new(type_def::Type))
          classes[typename] = klass
        else
          classes[typename] = type_def.const_get(typename)
        end
      end

      # Now go through them again and define attribute setter methods
      classes.each_pair do |typename, type|
        typeval = types_list['Types'][typename]
        next unless typeval.respond_to?(:each_pair)

        typeval.each_pair do |attr_name, attr_type|
          attr_method = attr_name
          variable = "@#{attr_name}".to_sym
          klass = nil

          if attr_type.is_a?(Array)
            klass = type_def.const_get(attr_type[0])
            singular_method = CfnDsl::Plurals.singularize(attr_name)

            if singular_method == attr_name
              # see if plural is different to singular
              attr_method = CfnDsl::Plurals.pluralize(attr_name)
            end

            define_array_method(klass, singular_method, type, variable) if singular_method != attr_method

          else
            klass = type_def.const_get(attr_type)
          end

          type.class_eval do
            CfnDsl.method_names(attr_method) do |inner_method|
              define_method(inner_method) do |value = nil, *_rest, &block|
                value ||= klass.new
                instance_variable_set(variable, value)
                value.instance_eval(&block) if block
                value
              end
            end
          end
        end
      end
    end

    def self.define_array_method(klass, singular_method, type, variable)
      type.class_eval do
        CfnDsl.method_names(singular_method).each do |method_name|
          define_method(method_name) do |value = nil, *rest, fn_if: nil, &block|
            existing = instance_variable_get(variable)
            # For no-op invocations, get out now
            return existing if value.nil? && rest.empty? && !block

            # We are going to modify the value in some
            # way, make sure that we have an array to mess
            # with if we start with nothing
            existing ||= instance_variable_set(variable, [])

            # special case for just a block, no args
            if value.nil? && rest.empty? && block
              val = klass.new
              existing.push(fn_if ? FnIf(fn_if, val, Ref('AWS::NoValue')) : val)
              val.instance_eval(&block)
              return existing
            end

            # Glue all of our parameters together into
            # a giant array - flattening one level deep, if needed
            array_params = []
            if value.is_a?(Array)
              array_params.concat(value)
            else
              array_params.push value
            end

            rest.each do |v|
              if v.is_a?(Array)
                array_params.concat(rest)
              else
                array_params.push v
              end
            end
            # Here, if we were given multiple arguments either
            # as method [a,b,c], method(a,b,c), or even
            # method( a, [b], c) we end up with
            # array_params = [a,b,c]
            #
            # array_params will have at least one item
            # unless the user did something like pass in
            # a bunch of empty arrays.
            if block
              array_params.each do |array_params_value|
                value = klass.new
                existing.push(fn_if ? FnIf(fn_if, value, Ref('AWS::NoValue')) : value)
                # This line never worked before, the useful thing to do is pass the array value to the block
                value.instance_exec(array_params_value, &block)
              end
            else
              # List of parameters with no block -
              # hope that the user knows what he is
              # doing and stuff them into our existing
              # array
              array_params.each do |v|
                existing.push v
              end
            end
            return existing
          end
        end
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  end
  # rubocop:enable Metrics/ModuleLength
end
