require 'cfndsl/jsonable'
require 'cfndsl/names'
require 'cfndsl/aws/types'
require 'cfndsl/os/types'
require 'cfndsl/globals'

module CfnDsl
  # Handles the overall template object
  # rubocop:disable Metrics/ClassLength
  class OrchestrationTemplate < JSONable
    dsl_attr_setter :AWSTemplateFormatVersion, :Description, :Metadata, :Transform
    dsl_content_object :Condition, :Parameter, :Output, :Resource, :Mapping

    GlobalRefs = {
      'AWS::NotificationARNs' => 1,
      'AWS::Region' => 1,
      'AWS::StackId' => 1,
      'AWS::StackName' => 1,
      'AWS::AccountId' => 1,
      'AWS::NoValue' => 1
    }.freeze

    class << self
      def create_types
        accessors = {}
        types_mapping = {}
        template_types['Resources'].each_pair do |resource, info|
          resource_name = create_resource_def(resource, info)
          parts = resource.split('::')
          until parts.empty?
            break if CfnDsl.reserved_items.include? parts.first
            abreve_name = parts.join('_')
            if accessors.key? abreve_name
              accessors.delete abreve_name # Delete potentially ambiguous names
            else
              accessors[abreve_name] = type_module.const_get resource_name
              types_mapping[abreve_name] = resource
            end
            parts.shift
          end
        end
        accessors.each_pair { |acc, res| create_resource_accessor(acc, res, types_mapping[acc]) }
      end

      def create_resource_def(name, info)
        resource = Class.new ResourceDefinition
        resource_name = name.gsub(/::/, '_')
        type_module.const_set(resource_name, resource)
        info['Properties'].each_pair do |pname, ptype|
          if ptype.is_a? Array
            pclass = type_module.const_get ptype.first
            create_array_property_def(resource, pname, pclass)
          else
            pclass = type_module.const_get ptype
            create_property_def(resource, pname, pclass)
          end
        end
        resource_name
      end

      def create_property_def(resource, pname, pclass)
        resource.class_eval do
          CfnDsl.method_names(pname) do |method|
            define_method(method) do |*values, &block|
              values.push pclass.new if values.empty?
              @Properties ||= {}
              @Properties[pname] = PropertyDefinition.new(*values)
              @Properties[pname].value.instance_eval(&block) if block
              @Properties[pname].value
            end
          end
        end
      end

      def create_array_property_def(resource, pname, pclass)
        create_property_def(resource, pname, Array)

        sname = CfnDsl::Plurals.singularize pname

        return if sname == pname
        resource.class_eval do
          CfnDsl.method_names(sname) do |method|
            define_method(method) do |value = nil, &block|
              @Properties ||= {}
              @Properties[pname] ||= PropertyDefinition.new([])
              value ||= pclass.new
              @Properties[pname].value.push value
              value.instance_eval(&block) if block
              value
            end
          end
        end
      end

      def create_resource_accessor(accessor, resource, type)
        class_eval do
          CfnDsl.method_names(accessor) do |method|
            define_method(method) do |name, *values, &block|
              name = name.to_s
              @Resources ||= {}
              @Resources[name] ||= resource.new(*values)
              @Resources[name].instance_eval(&block) if block
              @Resources[name].instance_variable_set('@Type', type)
              @Resources[name]
            end
          end
        end
      end
    end

    def initialize
      @AWSTemplateFormatVersion = '2010-09-09'
    end

    # rubocop:disable Metrics/PerceivedComplexity
    def valid_ref?(ref, origin = nil)
      ref = ref.to_s
      origin = origin.to_s if origin

      return true if GlobalRefs.key?(ref)

      return true if @Parameters && @Parameters.key?(ref)

      if @Resources.key?(ref)
        return !origin || !@_resource_refs || !@_resource_refs[ref] || !@_resource_refs[ref].key?(origin)
      end

      false
    end
    # rubocop:enable Metrics/PerceivedComplexity

    def check_refs
      invalids = check_resource_refs + check_output_refs
      invalids unless invalids.empty?
    end

    def check_resource_refs
      invalids = []
      @_resource_refs = {}
      if @Resources
        @Resources.each_key do |resource|
          @_resource_refs[resource.to_s] = @Resources[resource].build_references({})
        end
        @_resource_refs.each_key do |origin|
          @_resource_refs[origin].each_key do |ref|
            invalids.push "Invalid Reference: Resource #{origin} refers to #{ref}" unless valid_ref?(ref, origin)
          end
        end
      end
      invalids
    end

    def check_output_refs
      invalids = []
      output_refs = {}
      if @Outputs
        @Outputs.each_key do |resource|
          output_refs[resource.to_s] = @Outputs[resource].build_references({})
        end
        output_refs.each_key do |origin|
          output_refs[origin].each_key do |ref|
            invalids.push "Invalid Reference: Output #{origin} refers to #{ref}" unless valid_ref?(ref)
          end
        end
      end
      invalids
    end
  end
  # rubocop:enable Metrics/ClassLength
end
