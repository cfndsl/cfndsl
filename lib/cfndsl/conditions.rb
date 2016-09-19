require 'cfndsl/jsonable'

module CfnDsl
  # Handles condition objects
  #
  # Usage:
  #     Condition :ConditionName, FnEquals(Ref(:ParameterName), 'helloworld')
  class ConditionDefinition < JSONable
    include JSONSerialisableObject

    def initialize(value)
      @value = value
    end
  end
end
