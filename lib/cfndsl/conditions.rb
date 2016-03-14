require 'cfndsl/jsonable'

module CfnDsl
  class ConditionDefinition < JSONable
    #
    # Handles condition objects
    #
    # Usage:
    #     Condition :ConditionName, FnEqual(Ref(:ParameterName), 'helloworld')

    def initialize(value)
      @value = value
    end

    def to_json(*a)
      @value.to_json(*a)
    end
  end
end
