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
      if type_def::TYPE_PREFIX == 'aws'
        spec_file = YAML.safe_load File.open(CfnDsl.specification_file)
        resources = {}
        spec_file['ResourceTypes'].each do |resource_name, resource_info|
          properties = resource_info['Properties'].inject({}) do |extracted, (property_name, property_info)|
            if property_info['Type'] == 'Map' # how do we handle these?
              property_type = 'Json'
            elsif property_info['PrimitiveType']
              raise 'primitivetype had array' if property_info['Type'] == 'List'
              property_type = property_info['PrimitiveType']
            elsif property_info['PrimitiveItemType']
              raise 'primitiveitemtype didnt have array' unless property_info['Type'] == 'List'
              property_type = Array(property_info['PrimitiveItemType'])
            elsif property_info['ItemType']
              raise 'itemtype didnt have array' unless property_info['Type'] == 'List'
              if property_info['ItemType'] == 'Tag'
                property_type = 'Tag'
              else
                property_type = Array(resource_name.split('::').join + property_info['ItemType'])
              end
            elsif property_info['Type']
              raise 'type was last but still array' if property_info['Type'] == 'List'
              property_type = resource_name.split('::').join + property_info['Type']
            else
              raise 'couldnt extract type'
            end
            extracted[property_name] = property_type
            extracted
          end
          resources[resource_name] = { 'Properties' => properties }
        end
        types = {
          'Map'       => 'Map',
          'String'    => 'String',
          'Boolean'   => 'Boolean',
          'Json'      => 'Json',
          'Integer'   => 'Integer',
          'Number'    => 'Number',
          'Double'    => 'Double',
          'Timestamp' => 'Timestamp',
          'Long'      => 'Long',
        }
        spec_file['PropertyTypes'].each do |property_name, property_info|          
          root_resource = property_name.match(/(.*)\./)[1].gsub(/::/, '') rescue property_name # how do we track nodes?
          property_name = property_name.gsub(/::|\./, '') # fixme          
          properties = property_info['Properties'].inject({}) do |extracted, (nested_prop_name, nested_prop_info)|
            if nested_prop_info['Type'] == 'Map' # how do we handle these?
              nested_prop_type = 'Json'
            elsif nested_prop_info['PrimitiveType']
              raise 'primitivetype had array' if nested_prop_info['Type'] == 'List'
              nested_prop_type = nested_prop_info['PrimitiveType']
            elsif nested_prop_info['PrimitiveItemType']
              raise 'primitiveitemtype didnt have array' unless nested_prop_info['Type'] == 'List'
              nested_prop_type = Array(nested_prop_info['PrimitiveItemType'])
            elsif nested_prop_info['ItemType']
              raise 'itemtype didnt have array' unless nested_prop_info['Type'] == 'List'
              nested_prop_type = root_resource + nested_prop_info['ItemType']
              # nested_prop_type = Array(property_name.gsub(/::|\./, '') + nested_prop_info['ItemType'])
            elsif nested_prop_info['Type']
              raise 'type was last but still array' if nested_prop_info['Type'] == 'List'
              nested_prop_type = root_resource + nested_prop_info['Type']
              # nested_prop_type = property_name.gsub(/::|\./, '') + nested_prop_info['Type']
            else
              raise 'couldnt extract type'
            end
            extracted[nested_prop_name] = nested_prop_type
            extracted
          end
          types[property_name] = properties
        end
        File.open(File.expand_path('../../../new_types.yaml', __FILE__), 'w'){ |f| f.puts({ 'Resources' => resources, 'Types' => types }.to_yaml) }
        types_list = YAML.safe_load(File.open("#{File.dirname(__FILE__)}/#{type_def::TYPE_PREFIX}/types.yaml"))
        type_def.const_set('Types_Internal', types_list)
      else
        types_list = YAML.safe_load(File.open("#{File.dirname(__FILE__)}/#{type_def::TYPE_PREFIX}/types.yaml"))
        type_def.const_set('Types_Internal', types_list)
      end
      # Do a little sanity checking - all of the types referenced in Resources
      # should be represented in Types
      types_list['Resources'].keys.each do |resource_name|
        resource = types_list['Resources'][resource_name]
        resource.values.each do |thing|
          thing.values.each do |type|
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
          type.values.each do |tv|
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
          if attr_type.is_a?(Array)
            klass = type_def.const_get(attr_type[0])
            variable = "@#{attr_name}".to_sym

            method = CfnDsl::Plurals.singularize(attr_name)
            methods = attr_name
            all_methods = CfnDsl.method_names(method) + CfnDsl.method_names(methods)
            type.class_eval do
              all_methods.each do |method_name|
                define_method(method_name) do |value = nil, *rest, &block|
                  existing = instance_variable_get(variable)
                  # For no-op invocations, get out now
                  return existing if value.nil? && rest.empty? && !block

                  # We are going to modify the value in some
                  # way, make sure that we have an array to mess
                  # with if we start with nothing
                  existing = instance_variable_set(variable, []) unless existing

                  # special case for just a block, no args
                  if value.nil? && rest.empty? && block
                    val = klass.new
                    existing.push val
                    value.instance_eval(&block(val))
                    return existing
                  end

                  # Glue all of our parameters together into
                  # a giant array - flattening one level deep, if needed
                  array_params = []
                  if value.is_a?(Array)
                    value.each { |x| array_params.push x }
                  else
                    array_params.push value
                  end
                  unless rest.empty?
                    rest.each do |v|
                      if v.is_a?(Array)
                        array_params += rest
                      else
                        array_params.push v
                      end
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
                      existing.push value
                      value.instance_eval(&block(array_params_value)) if block
                    end
                  else
                    # List of parameters with no block -
                    # hope that the user knows what he is
                    # doing and stuff them into our existing
                    # array
                    array_params.each do |_|
                      existing.push value
                    end
                  end
                  return existing
                end
              end
            end
          else
            klass = type_def.const_get(attr_type)
            variable = "@#{attr_name}".to_sym

            type.class_eval do
              CfnDsl.method_names(attr_name) do |inner_method|
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
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  end
  # rubocop:enable Metrics/ModuleLength
end
