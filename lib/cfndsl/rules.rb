# frozen_string_literal: true

require 'cfndsl/jsonable'

module CfnDsl
  # Handles Rule objects
  class RuleDefinition < JSONable
    dsl_attr_setter :RuleCondition, :Assertions

    def initialize(value = nil)
      @Assertions = value[:Assertions] if value[:Assertions]
      @RuleCondition = value[:RuleCondition] if value[:RuleCondition]
    end
  end
end
