require 'cfndsl/jsonable'

module CfnDsl
  # Handles Metadata objects
  class MetadataDefinition < JSONable
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_json(*a)
      @value.to_json(*a)
    end
  end
end
