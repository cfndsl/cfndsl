# frozen_string_literal: true

require_relative 'jsonable'

module CfnDsl
  # Handles Resource objects
  class ResourceDefinition < JSONable
    dsl_attr_setter :Type, :DependsOn, :UpdateReplacePolicy, :DeletionPolicy, :Condition, :Metadata
    dsl_content_object :Property, :UpdatePolicy, :CreationPolicy

    def add_tag(name, value, propagate = nil)
      send(:Tag) do
        Key name
        Value value
        PropagateAtLaunch propagate unless propagate.nil?
      end
    end

    def condition_refs
      [@Condition].flatten.compact.map(&:to_s)
    end

    def all_refs
      [@DependsOn].flatten.compact.map(&:to_s)
    end
  end
end
