require 'cfndsl/jsonable'

module CfnDsl
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
  class UpdatePolicyDefinition < JSONable
    attr_reader :value
    def initialize(value)
      @value = value
    end

    def to_json(*a)
      @value.to_json(*a)
    end
  end
end
