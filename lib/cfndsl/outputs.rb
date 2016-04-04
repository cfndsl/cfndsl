require 'cfndsl/jsonable'

module CfnDsl
  # Handles Output objects
  class OutputDefinition < JSONable
    dsl_attr_setter :Value, :Description, :Condition

    def initialize(value = nil)
      @Value = value if value
    end
  end
end
