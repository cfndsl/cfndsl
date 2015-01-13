require 'cfndsl/JSONable'
require 'cfndsl/Metadata'
require 'cfndsl/Properties'
require 'cfndsl/UpdatePolicy'

module CfnDsl
  class ResourceDefinition < JSONable
    ##
    # Handles Resource objects
    dsl_attr_setter :Type, :DependsOn, :DeletionPolicy, :Condition
    dsl_content_object :Property, :Metadata, :UpdatePolicy, :CreationPolicy

    def addTag(name, value, propagate=nil)
      self.send(:Tag) {
        Key name
        Value value
        PropagateAtLaunch propagate unless propagate.nil?
      }
    end

    def get_references()
      refs = []
      if @DependsOn then
        if( @DependsOn.respond_to?(:each) ) then
          @DependsOn.each do |dep|
            refs.push dep
          end
        end

        if( @DependsOn.instance_of?(String) ) then
          refs.push @DependsOn
        end
      end
      refs
    end
  end
end
