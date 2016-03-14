require 'cfndsl/jsonable'

module CfnDsl
  class CreationPolicyDefinition < JSONable
    ##
    # Handles creation policy objects for Resources
    #
    # Usage
    #   Resource("aaa") {
    #     CreationPolicy('ResourceSignal', { 'Count' => 1,  'Timeout' => 'PT10M' })
    #   }
    #
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_json(*a)
      @value.to_json(*a)
    end
  end
end
