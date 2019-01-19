# frozen_string_literal: true

require 'yaml'
require 'cfndsl/jsonable'
require 'cfndsl/plurals'
require 'cfndsl/names'
require 'cfndsl/types'

module CfnDsl
  # Types helper
  # rubocop:disable Metrics/ModuleLength
  module Types
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    def self.included(type_def)
      types_list = if type_def::TYPE_PREFIX == 'aws'
                     Specification.extract_from_resource_spec!
                   else
                     YAML.safe_load(File.open("#{File.dirname(__FILE__)}/#{type_def::TYPE_PREFIX}/types.yaml"))
                   end
      type_def.const_set('Types_Internal', types_list)
      # Do a little sanity checking - all of the types referenced in Resources
      # should be represented in Types
      types_list['Resources'].each_key do |resource_name|
        resource = types_list['Resources'][resource_name]
        resource.each_value do |thing|
          thing.each_value do |type|
            if type.is_a?(Array)
              type.each do |inner_type|
                puts "unknown type #{inner_type}" unless types_list['Types'].key?(inner_type)
              end
            else
              puts "unknown type #{type}" unless types_list['Types'].key?(type)
            end
          end
        end
      end

      # All of the type values should also be references
      types_list['Types'].values do |type|
        if type.respond_to?(:values)
          type.each_value do |tv|
            puts "unknown type #{tv}" unless types_list['Types'].key?(tv)
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
