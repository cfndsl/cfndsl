require 'cfndsl/jsonable'

module CfnDsl
  # Handles property objects for Resources
  #
  # Usage
  #   Resource("aaa") {
  #     Property("propName", "propValue" )
  #   }
  #
  class PropertyDefinition < JSONable
    include JSONSerialisableObject

    attr_reader :value

    def initialize(value)
      @value = value
    end
  end
end
