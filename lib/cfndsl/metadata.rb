require 'cfndsl/jsonable'

module CfnDsl
  class MetadataDefinition < JSONable
    attr_reader :value

    ##
    # Handles Metadata objects
    def initialize(value)
      @value = value
    end

    def to_json(*a)
      @value.to_json(*a)
    end
  end
end
