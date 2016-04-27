require 'cfndsl/jsonable'

module CfnDsl
  # Handles Metadata objects
  class MetadataDefinition < JSONable
    include JSONSerialisableObject

    attr_reader :value

    def initialize(value)
      @value = value
    end
  end
end
