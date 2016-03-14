require 'cfndsl/jsonable'
require 'cfndsl/names'

module CfnDsl
  class OrchestrationTemplate < JSONable
    ##
    # Handles the overall template object
    dsl_attr_setter :AWSTemplateFormatVersion, :Description
    dsl_content_object :Condition, :Parameter, :Output, :Resource, :Mapping

    def initialize
      @AWSTemplateFormatVersion = '2010-09-09'
    end

    @@globalRefs = {
      'AWS::NotificationARNs' => 1,
      'AWS::Region' => 1,
      'AWS::StackId' => 1,
      'AWS::StackName' => 1,
      'AWS::AccountId' => 1,
      'AWS::NoValue' => 1
    }

    def valid_ref?(ref, origin = nil)
      ref = ref.to_s
      origin = origin.to_s if origin

      return true if @@globalRefs.key?(ref)

      return true if @Parameters && @Parameters.key?(ref)

      if @Resources.key?(ref)
        return !origin || !@_resource_refs || !@_resource_refs[ref] || !@_resource_refs[ref].key?(origin)
      end

      false
    end

    def check_refs
      invalids = []

      @_resource_refs = {}
      if @Resources
        @Resources.keys.each do |resource|
          @_resource_refs[resource.to_s] = @Resources[resource].references({})
        end
        @_resource_refs.keys.each do |origin|
          @_resource_refs[origin].keys.each do |ref|
            invalids.push "Invalid Reference: Resource #{origin} refers to #{ref}" unless valid_ref?(ref, origin)
          end
        end
      end

      output_refs = {}
      if @Outputs
        @Outputs.keys.each do |resource|
          output_refs[resource.to_s] = @Outputs[resource].references({})
        end
        output_refs.keys.each do |origin|
          output_refs[origin].keys.each do |ref|
            invalids.push "Invalid Reference: Output #{origin} refers to #{ref}" unless valid_ref?(ref)
          end
        end
      end

      invalids.empty? ? nil : invalids
    end
  end

  class CloudFormationTemplate < OrchestrationTemplate
    def self.template_types
      CfnDsl::AWSTypes::AWS_Types
    end

    def self.type_module
      CfnDsl::AWSTypes
    end

    names = {}
    nametypes = {}
    template_types['Resources'].each_pair do |name, type|
      # Subclass ResourceDefintion and generate property methods
      klass = Class.new(CfnDsl::ResourceDefinition)
      klassname = name.split('::').join('_')
      type_module.const_set(klassname, klass)
      type['Properties'].each_pair do |pname, ptype|
        if ptype.instance_of?(String)
          create_klass = type_module.const_get(ptype)

          klass.class_eval do
            CfnDsl.method_names(pname) do |method|
              define_method(method) do |*values, &block|
                values.push create_klass.new if values.empty?

                @Properties ||= {}
                @Properties[pname] = CfnDsl::PropertyDefinition.new(*values)
                @Properties[pname].value.instance_eval(&block) if block
                @Properties[pname].value
              end
            end
          end
        else
          # Array version
          sing_name = CfnDsl::Plurals.singularize(pname)
          create_klass = type_module.const_get(ptype[0])
          klass.class_eval do
            CfnDsl.method_names(pname) do |method|
              define_method(method) do |*values, &block|
                values.push [] if values.empty?
                @Properties ||= {}
                @Properties[pname] ||= PropertyDefinition.new(*values)
                @Properties[pname].value.instance_eval(&block) if block
                @Properties[pname].value
              end
            end

            CfnDsl.method_names(sing_name) do |method|
              define_method(method) do |value = nil, &block|
                @Properties ||= {}
                @Properties[pname] ||= PropertyDefinition.new([])
                value = create_klass.new unless value
                @Properties[pname].value.push value
                value.instance_eval(&block) if block
                value
              end
            end
          end
        end
      end
      parts = name.split('::')
      until parts.empty?
        abreve_name = parts.join('_')
        if names.key?(abreve_name)
          # this only happens if there is an ambiguity
          names[abreve_name] = nil
        else
          names[abreve_name] = type_module.const_get(klassname)
          nametypes[abreve_name] = name
        end
        parts.shift
      end
    end

    # Define property setter methods for each of the unambiguous type names
    names.each_pair do |typename, type|
      next unless type

      class_eval do
        CfnDsl.method_names(typename) do |method|
          define_method(method) do |name, *values, &block|
            name = name.to_s
            @Resources ||= {}
            resource = @Resources[name] ||= type.new(*values)
            resource.instance_eval(&block) if block
            resource.instance_variable_set('@Type', nametypes[typename])
            resource
          end
        end
      end
    end
  end

  class HeatTemplate < OrchestrationTemplate
    def self.template_types
      CfnDsl::OSTypes::OS_Types
    end

    def self.type_module
      CfnDsl::OSTypes
    end

    names = {}
    nametypes = {}
    template_types['Resources'].each_pair do |name, type|
      # Subclass ResourceDefintion and generate property methods
      klass = Class.new(CfnDsl::ResourceDefinition)
      klassname = name.split('::').join('_')
      type_module.const_set(klassname, klass)
      type['Properties'].each_pair do |pname, ptype|
        if ptype.instance_of?(String)
          create_klass = type_module.const_get(ptype)

          klass.class_eval do
            CfnDsl.method_names(pname) do |method|
              define_method(method) do |*values, &block|
                values.push create_klass.new if values.empty?
                @Properties ||= {}
                @Properties[pname] = CfnDsl::PropertyDefinition.new(*values)
                @Properties[pname].value.instance_eval(&block) if block
                @Properties[pname].value
              end
            end
          end
        else
          # Array version
          sing_name = CfnDsl::Plurals.singularize(pname)
          create_klass = type_module.const_get(ptype[0])
          klass.class_eval do
            CfnDsl.method_names(pname) do |method|
              define_method(method) do |*values, &block|
                values.push [] if values.empty?
                @Properties ||= {}
                @Properties[pname] ||= PropertyDefinition.new(*values)
                @Properties[pname].value.instance_eval(&block) if block
                @Properties[pname].value
              end
            end

            CfnDsl.method_names(sing_name) do |method|
              define_method(method) do |value = nil, &block|
                @Properties ||= {}
                @Properties[pname] ||= PropertyDefinition.new([])
                value = create_klass.new unless value
                @Properties[pname].value.push value
                value.instance_eval(&block) if block
                value
              end
            end
          end
        end
      end

      parts = name.split('::')
      until parts.empty?
        abreve_name = parts.join('_')
        if names.key?(abreve_name)
          # this only happens if there is an ambiguity
          names[abreve_name] = nil
        else
          names[abreve_name] = type_module.const_get(klassname)
          nametypes[abreve_name] = name
        end
        parts.shift
      end
    end

    # Define property setter methods for each of the unambiguous type names
    names.each_pair do |typename, type|
      next unless type

      class_eval do
        CfnDsl.method_names(typename) do |method|
          define_method(method) do |name, *values, &block|
            name = name.to_s
            @Resources ||= {}
            resource = @Resources[name] ||= type.new(*values)
            resource.instance_eval(&block) if block
            resource.instance_variable_set('@Type', nametypes[typename])
            resource
          end
        end
      end
    end
  end
end
