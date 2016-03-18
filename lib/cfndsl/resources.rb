require 'cfndsl/jsonable'
require 'cfndsl/metadata'
require 'cfndsl/properties'
require 'cfndsl/update_policy'

module CfnDsl
  # Handles Resource objects
  class ResourceDefinition < JSONable
    dsl_attr_setter :Type, :DependsOn, :DeletionPolicy, :Condition
    dsl_content_object :Property, :Metadata, :UpdatePolicy, :CreationPolicy

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
  end
end
