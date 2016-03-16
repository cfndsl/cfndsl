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
    attr_reader :value
    def initialize(value)
      @value = value
    end

    def to_json(*a)
      @value.to_json(*a)
    end
  end
end
