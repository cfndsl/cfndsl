require 'cfndsl/jsonable'
require 'cfndsl/metadata'
require 'cfndsl/properties'
require 'cfndsl/update_policy'

module CfnDsl
  # Handles Resource objects
  class ResourceDefinition < JSONable
    dsl_attr_setter :Type, :DependsOn, :DeletionPolicy, :Condition
    dsl_content_object :Property, :Metadata, :UpdatePolicy, :CreationPolicy

    # rubocop:disable UnusedMethodArgument
    # rubocop:disable UselessAssignment
    def addTag(name, value, propagate = nil)
      logstream.puts("This method is deprecated and will be removed in the next major release, please use 'add_tag' instead.") if logstream
      add_tag(name, value, propagate = nil)
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
  end
end
