require 'cfndsl/JSONable'

module CfnDsl  
  class CreationPolicyDefinition < JSONable
    ##
    # Handles creation policy objects for Resources
    #
    # Usage
    #   Resource("aaa") {
    #     CreationPolicy('ResourceSignal', { 'Count' => 1,  'Timeout' => 'PT10M' })
    #   }
    #
    def initialize(value) 
      @value = value;
    end

    def value
      return @value
    end
    
    def to_json(*a) 
      @value.to_json(*a)
    end
  end
end
