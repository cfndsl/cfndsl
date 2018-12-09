# frozen_string_literal: true

require 'cfndsl/jsonable'

module CfnDsl
  # Handles Output objects
  class OutputDefinition < JSONable
    dsl_attr_setter :Value, :Description, :Condition

    def Export(value)
      @Export = { 'Name' => value } if value
    end

    def initialize(value = nil)
      @Value = value if value
    end

    def condition
      @Condition
    end
  end
end
