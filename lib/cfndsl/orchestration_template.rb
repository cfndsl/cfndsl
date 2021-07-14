# frozen_string_literal: true

require_relative 'globals'
require_relative 'module'
require_relative 'jsonable'
require_relative 'names'
require_relative 'plurals'
require_relative 'ref_check'
require_relative 'properties'
require_relative 'update_policy'
require_relative 'creation_policy'
require_relative 'conditions'
require_relative 'mappings'
require_relative 'resources'
require_relative 'rules'
require_relative 'parameters'
require_relative 'outputs'

require 'tsort'

module CfnDsl
  # Handles the overall template object
  # rubocop:disable Metrics/ClassLength
  class OrchestrationTemplate < JSONable
    dsl_attr_setter :AWSTemplateFormatVersion, :Description, :Metadata, :Transform, :Hooks
    dsl_content_object :Condition, :Parameter, :Output, :Resource, :Mapping, :Rule

    GLOBAL_REFS = {
      'AWS::NotificationARNs' => 1,
      'AWS::Region' => 1,
      'AWS::StackId' => 1,
      'AWS::StackName' => 1,
      'AWS::AccountId' => 1,
      'AWS::NoValue' => 1,
      'AWS::URLSuffix' => 1,
      'AWS::Partition' => 1
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
            raise CfnDsl::Error, "Cannot override previously defined Type #{@Type} with #{type}" unless type == @Type

            super
          end
        end
        resource_name = name.gsub(/::/, '_')
        type_module.const_set(resource_name, resource)
        info['Properties'].each_pair do |pname, ptype|
          # handle bogus List defined as Type
          unless ptype.is_a?(Array)
            pclass = type_module.const_get ptype
            if pclass.is_a?(Array)
              ptype = pclass
            else
              create_property_def(resource, pname, pclass)
            end
          end

          if ptype.is_a? Array
            pclass = type_module.const_get ptype.first
            create_array_property_def(resource, pname, pclass, info)
          end
        end
        resource_name
      end

      def create_array_property_def(resource, pname, pclass, info)
        singular_name = CfnDsl::Plurals.singularize pname
        plural_name = singular_name == pname ? CfnDsl::Plurals.pluralize(pname) : pname

        if singular_name == plural_name
          # Generate the extended list concat method
          plural_name = nil
        elsif pname == plural_name && info['Properties'].include?(singular_name)
          # The singlular name is a different property, do not redefine it here but rather use the extended form
          #  with the plural name. This allows construction of deep types, but no mechanism to overwrite a previous value
          # (eg CodePipeline::Pipeline ArtifactStores vs ArtifactStore)
          # Note is is also possible (but unlikely) for the spec to change in a way that triggers this condition where it did not
          # before which will result in breaking behaviour for existing apps.
          singular_name = plural_name
          plural_name = nil
        elsif pname == singular_name && info['Properties'].include?(plural_name)
          # The plural name is a different property, do not redefine it here
          # Note it is unlikely that a singular form is going to be a List property if the plural form also exists.
          plural_name = singular_name
        end

        # Plural form just a normal property definition expecting an Array type
        create_property_def(resource, pname, Array, plural_name) if plural_name

        # Singular form understands concatenation and Fn::If property
        create_singular_property_def(resource, pname, pclass, singular_name) if singular_name
      end

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

      private

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

      def create_singular_property_def(resource, pname, pclass, singular_name)
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
    end

    def initialize(description = nil, &block)
      @AWSTemplateFormatVersion = '2010-09-09'
      @Description = description if description
      declare(&block) if block_given?
    end

    alias _Condition Condition

    # Condition has two usages at this level
    # @overload Condition(name,expression)
    # @overload Condition(name) - referencing a condition in a condition expression
    def Condition(name, expression = nil)
      if expression
        _Condition(name, expression)
      else
        { Condition: ConditionDefinition.new(name) }
      end
    end

    def check_refs
      invalids = check_condition_refs + check_resource_refs + check_output_refs + check_rule_refs
      invalids unless invalids.empty?
    end

    def valid_ref?(ref, ref_containers = [GLOBAL_REFS, @Resources, @Parameters])
      ref = ref.to_s
      ref_containers.any? { |c| c && c.key?(ref) }
    end

    def check_condition_refs
      invalids = []

      # Conditions can refer to other conditions in Fn::And, Fn::Or and Fn::Not
      invalids.concat(_check_refs(:Condition, :condition_refs, [@Conditions]))

      # They can also Ref Globals and Parameters (but not Resources))
      invalids.concat(_check_refs(:Condition, :all_refs, [GLOBAL_REFS, @Parameters]))
    end

    def check_resource_refs
      invalids = []
      invalids.concat(_check_refs(:Resource, :all_refs, [@Resources, GLOBAL_REFS, @Parameters]))

      # DependsOn and conditions in Fn::If expressions
      invalids.concat(_check_refs(:Resource, :condition_refs, [@Conditions]))
    end

    def check_output_refs
      invalids = []
      invalids.concat(_check_refs(:Output, :all_refs, [@Resources, GLOBAL_REFS, @Parameters]))
      invalids.concat(_check_refs(:Output, :condition_refs, [@Conditions]))
    end

    def check_rule_refs
      invalids = []
      invalids.concat(_check_refs(:Rule, :all_refs, [@Resources, GLOBAL_REFS, @Parameters]))
      invalids.concat(_check_refs(:Rule, :condition_refs, [@Conditions]))
      invalids
    end

    # For testing for cycles
    class RefHash < Hash
      include TSort

      alias tsort_each_node each_key
      def tsort_each_child(node, &block)
        fetch(node, []).each(&block)
      end
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def _check_refs(container_name, method, source_containers)
      container = instance_variable_get("@#{container_name}s")
      return [] unless container

      invalids = []
      referred_by = RefHash.new { |h, k| h[k] = [] }
      self_check = source_containers.first.eql?(container)

      container.each_pair do |name, entry|
        name = name.to_s
        begin
          refs = entry.build_references([], self_check && name, method)
          refs.each { |r| referred_by[r.to_s] << name }
        rescue RefCheck::SelfReference, RefCheck::NullReference => e
          # Topological sort will not detect self or null references
          invalids.push("#{container_name} #{e.message}")
        end
      end

      referred_by.each_pair do |ref, names|
        unless valid_ref?(ref, source_containers)
          invalids.push "Invalid Reference: #{container_name}s #{names} refer to unknown #{method == :condition_refs ? 'Condition' : 'Reference'} #{ref}"
        end
      end

      begin
        referred_by.tsort if self_check && invalids.empty? # Check for cycles
      rescue TSort::Cyclic => e
        invalids.push "Cyclic references found in #{container_name}s #{referred_by} - #{e.message}"
      end

      invalids
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def validate
      errors = check_refs || []
      raise CfnDsl::Error, "#{errors.size} errors in template\n#{errors.join("\n")}" unless errors.empty?

      self
    end
  end
  # rubocop:enable Metrics/ClassLength
end
