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

    def condition_refs
      [@Condition].flatten.compact.map(&:to_s)
    end

    def all_refs
      [@DependsOn].flatten.compact.map(&:to_s)
    end
  end
end
