require 'cfndsl/JSONable'

module CfnDsl
  class OutputDefinition < JSONable
    ##
    # Handles Output objects
    dsl_attr_setter :Value, :Description, :Condition

    def initialize( value=nil)
      @Value = value if value
    end
  end
end
