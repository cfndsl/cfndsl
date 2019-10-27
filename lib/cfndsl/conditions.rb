# frozen_string_literal: true

require_relative 'jsonable'

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

    # For when Condition is used inside Fn::And, Fn::Or, Fn::Not
    def condition_refs
      case @value
      when String, Symbol
        [@value.to_s]
      else
        []
      end
    end
  end
end
