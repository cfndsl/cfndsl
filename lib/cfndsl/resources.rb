# frozen_string_literal: true

require 'cfndsl/jsonable'
require 'cfndsl/properties'
require 'cfndsl/update_policy'

module CfnDsl
  # Handles Resource objects
  class ResourceDefinition < JSONable
    dsl_attr_setter :Type, :DependsOn, :DeletionPolicy, :Condition, :Metadata
    dsl_content_object :Property, :UpdatePolicy, :CreationPolicy

    def addTag(name, value, propagate = nil)
      add_tag(name, value, propagate)
    end

    def add_tag(name, value, propagate = nil)
      send(:Tag) do
        Key name
        Value value
        PropagateAtLaunch propagate unless propagate.nil?
      end
    end

    def all_refs
      refs = []
      if @DependsOn
        if @DependsOn.respond_to?(:each)
          @DependsOn.each do |dep|
            refs.push dep
          end
        end

        refs.push @DependsOn if @DependsOn.instance_of?(String)
      end

      refs
    end

    def depends_on
      all_refs # Not actually all refs, only depends on
    end

    def condition
      @Condition
    end
  end
end
