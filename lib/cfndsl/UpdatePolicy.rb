require 'cfndsl/JSONable'

module CfnDsl  
  class UpdatePolicyDefinition < JSONable
    ##
    # Handles autoscaling group update policy objects for Resources
    #
    # Usage
    #   Resource("aaa") {
    #     UpdatePolicy("AutoScalingRollingUpdate", {    
    #       "MinInstancesInService" => "1",
    #       "MaxBatchSize" => "1",
    #       "PauseTime" => "PT12M5S"
    #     })
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
