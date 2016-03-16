require 'cfndsl/jsonable'

module CfnDsl
  # Handles condition objects
  #
  # Usage:
  #     Condition :ConditionName, FnEqual(Ref(:ParameterName), 'helloworld')
  class ConditionDefinition < JSONable
    def initialize(value)
      @value = value
    end

    def to_json(*a)
      @value.to_json(*a)
    end
  end
end
