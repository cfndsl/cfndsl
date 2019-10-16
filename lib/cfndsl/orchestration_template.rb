# frozen_string_literal: true

require 'cfndsl/jsonable'
require 'cfndsl/names'
require 'cfndsl/aws/types'
require 'cfndsl/globals'
require 'set'

module CfnDsl
  # Handles the overall template object
  # rubocop:disable Metrics/ClassLength
  class OrchestrationTemplate < JSONable
    dsl_attr_setter :AWSTemplateFormatVersion, :Description, :Metadata, :Transform
    dsl_content_object :Condition, :Parameter, :Output, :Resource, :Mapping

    GLOBAL_REFS = {
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
              accessors[abreve_name] = :duplicate # Delete potentially ambiguous names
            else
              accessors[abreve_name] = type_module.const_get resource_name
              types_mapping[abreve_name] = resource
            end
            parts.shift
          end
        end
        accessors.each_pair { |acc, res| create_resource_accessor(acc, res, types_mapping[acc]) unless res == :duplicate }
      end

      def create_resource_def(name, info)
        resource = Class.new ResourceDefinition do
          # do not allow Type to be respecified
          def Type(type = nil)
            return @Type unless type
            raise CfnDsl::Error, "Cannot override Type for #{name}" unless type == @Type

            super
          end
        end
        resource_name = name.gsub(/::/, '_')
        type_module.const_set(resource_name, resource)
        info['Properties'].each_pair do |pname, ptype|
          if ptype.is_a? Array
            pclass = type_module.const_get ptype.first rescue nil # TODO: Temporary fix for 1.0.0-pre tests against new spec
            create_array_property_def(resource, pname, pclass, info) if pclass #TODO
          else
            pclass = type_module.const_get ptype rescue nil # TODO: Temporary fix for 1.0.0-pre tests against new spec
            create_property_def(resource, pname, pclass) if pclass #TODO
          end
        end
        resource_name
      end

      def create_property_def(resource, pname, pclass, method_name = pname)
        resource.class_eval do
          CfnDsl.method_names(method_name) do |method|
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

      # rubocop:disable Metrics/PerceivedComplexity,Metrics/MethodLength
      def create_array_property_def(resource, pname, pclass, info)
        singular_name = CfnDsl::Plurals.singularize pname

        # if the singular version exists, don't smash it into somethin it's not
        # e.g. ArtifactStore and ArtifactStores in AWS::CodePipeline::Pipeline
        return if info['Properties'].include? singular_name

        plural_name =
          if singular_name == pname
            # eg VPCZoneIdentifier is a list property
            # its singular name is VPCZoneIdentifier
            # its plural name is VPCZoneIdentifiers
            CfnDsl::Plurals.pluralize(pname)
          else
            pname
          end

        create_property_def(resource, pname, Array, plural_name)



        # But if singular and plural are the same
        # eg SecurityGroupEgress, then we treat it as the plural property only
        return if singular_name == plural_name

        resource.class_eval do
          CfnDsl.method_names(singular_name) do |method|
            define_method(method) do |value = nil, fn_if: nil, **hash_value, &block|
              value = hash_value unless value || hash_value.empty?
              @Properties ||= {}
              @Properties[pname] ||= PropertyDefinition.new([])
              if value.is_a?(Array)
                @Properties[pname].value.concat(value)
              else
                value ||= pclass.new
                @Properties[pname].value.push fn_if ? FnIf(fn_if, value, Ref('AWS::NoValue')) : value
                value.instance_eval(&block) if block
              end
              value
            end
          end
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity,Metrics/MethodLength

      def create_resource_accessor(accessor, resource, type)
        class_eval do
          CfnDsl.method_names(accessor) do |method|
            define_method(method) do |name, *values, &block|
              name = name.to_s
              @Resources ||= {}
              instance = @Resources[name]
              if !instance
                instance = resource.new(*values)
                # Previously the type was set after the block was evaled
                # But now trying to reset Type on a specific subtype will raise exception
                instance.instance_variable_set('@Type', type)
                @Resources[name] = instance
              elsif type != (other_type = instance.instance_variable_get('@Type'))
                raise ArgumentError, "Resource #{name}<#{other_type}> exists, and is not a <#{type}>"
              elsif !values.empty?
                raise ArgumentError, "wrong number of arguments (given #{values.size + 1}, expected 1) as Resource #{name} already exists"
              end
              @Resources[name].instance_eval(&block) if block
              instance
            end
          end
        end
      end
    end

    def initialize(description = nil, &block)
      @AWSTemplateFormatVersion = '2010-09-09'
      @Description = description if description
      declare(&block) if block_given?
    end

    # rubocop:disable Metrics/PerceivedComplexity
    def valid_ref?(ref, origin = nil)
      ref = ref.to_s
      origin = origin.to_s if origin

      return true if GLOBAL_REFS.key?(ref)

      return true if @Parameters && @Parameters.key?(ref)

      return !origin || !@_resource_refs || !@_resource_refs[ref] || !@_resource_refs[ref].key?(origin) if @Resources.key?(ref)

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

    # rubocop:disable  Metrics/AbcSize, Metrics/PerceivedComplexity
    def validate_resources(errors = [])
      resources = (@Resources || {})
      conditions = (@Conditions || {})
      parameters = (@Parameters || {})

      dependencies = resources.each.with_object({}) do |(logical_id, resource), resource_dependencies|
        path = "/Resources/#{logical_id}"

        unless !resource.condition || conditions.include?(resource.condition)
          errors << "Invalid Condition : Resource #{logical_id} refers to missing Condition #{resource.condition}"
        end

        depends_on = resource.visit_json(path).with_object(Set.new(resource.depends_on)) do |(sub_path, value), resource_depends_on|
          if value.nil?
            errors << "Null value at #{sub_path} is not permitted"
          elsif !(value_refs = value.respond_to?(:refs) ? value.refs - GLOBAL_REFS.keys : []).empty?
            resource_refs = value_refs - parameters.keys
            invalid_refs = resource_refs - resources.keys
            if invalid_refs.empty?
              resource_depends_on.merge(resource_refs) # Don't check for cyclic dependencies where references are not valid anyway
            else
              errors << "Invalid References : Path #{sub_path} refers to #{invalid_refs}"
            end

          end
        end

        resource_dependencies[logical_id] = depends_on
      end

      _validate_dependency_cycles(dependencies, errors)

      errors
    end
    # rubocop:enable  Metrics/AbcSize, Metrics/PerceivedComplexity

    # @api private
    # rubocop:disable Metrics/PerceivedComplexity
    def _validate_dependency_cycles(dependencies, errors = [], logical_id = nil, visited = Set.new)
      if logical_id
        visited << logical_id
        depends_on = dependencies[logical_id]
        if (cycles = depends_on & visited).any?
          errors << "Found cyclic dependency for #{logical_id} to #{cycles.to_a}"
        else
          depends_on.each do |depends_on_logical_id|
            if dependencies.key?(depends_on_logical_id)
              _validate_dependency_cycles(dependencies, errors, depends_on_logical_id, visited)
            else
              errors << "#{logical_id} DependsOn unknown resource #{depends_on_logical_id}"
            end
            break unless errors.empty?
          end
        end
      else
        dependencies.keys.each do |dependency_logical_id|
          _validate_dependency_cycles(dependencies, errors, dependency_logical_id)
          break unless errors.empty?
        end
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity

    # rubocop:disable Metrics/PerceivedComplexity
    def validate_conditions(errors = [])
      conditions = (@Conditions || {})
      parameter_refs = (@Parameters || {}).keys

      conditions.each_pair do |logical_id, condition|
        path = "/Conditions/#{logical_id}"

        condition.visit_json(path) do |sub_path, value|
          if value.nil?
            errors << "Null value at #{sub_path} is not permitted"
          elsif !(value_refs = value.respond_to?(:refs) ? value.refs - GLOBAL_REFS.keys : []).empty?
            invalid_refs = value_refs - parameter_refs
            errors << "Invalid References : Path #{sub_path} refers to #{invalid_refs}" unless invalid_refs.empty?
          end
        end
      end

      # TODO: condition functions Fn::Not, Fn::Or, Fn::And can refer to other conditions, and these cannot be cyclic either
      errors
    end
    # rubocop:enable Metrics/PerceivedComplexity

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
    def validate_outputs(errors = [])
      outputs = (@Outputs || {})
      conditions = (@Conditions || {})
      parameters = (@Parameters || {})
      resources = (@Resources || {})

      outputs.each_pair do |logical_id, output|
        path = "/Outputs/#{logical_id}"

        unless !output.condition || conditions.include?(output.condition)
          errors << "Invalid Condition : Output #{logical_id} refers to missing Condition #{output.condition}"
        end

        output.visit_json(path) do |sub_path, value|
          if value.nil?
            errors << "Null value at #{sub_path} is not permitted"
          elsif !(value_refs = value.respond_to?(:refs) ? value.refs - GLOBAL_REFS.keys : []).empty?
            output_refs = value_refs - parameters.keys
            invalid_refs = output_refs - resources.keys
            errors << "Invalid References : Path #{sub_path} refers to #{invalid_refs}" unless invalid_refs.empty?
          end
        end
      end

      errors
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize

    def validate
      errors = []
      validate_conditions(errors)
      validate_resources(errors)
      validate_outputs(errors)
      raise CfnDsl::Error, "#{errors.size} errors in template\n#{errors.join("\n")}" unless errors.empty?

      self
    end
  end
  # rubocop:enable Metrics/ClassLength
end
