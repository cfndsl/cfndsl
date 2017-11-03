require 'cfndsl/jsonable'
require 'cfndsl/properties'
require 'cfndsl/update_policy'

module CfnDsl
  # Handles Resource objects
  class ResourceDefinition < JSONable
    dsl_attr_setter :Type, :DependsOn, :DeletionPolicy, :Condition, :Metadata
    dsl_content_object :Property, :UpdatePolicy, :CreationPolicy

    def addTag(name, value)
      add_tag(name, value)
    end

    def add_tag(name, value)
      send(:Tag) do
        Key name
        Value value
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
