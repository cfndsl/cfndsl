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
    include JSONSerialisableObject

    attr_reader :value

    def initialize(value)
      @value = value
    end
  end
end
