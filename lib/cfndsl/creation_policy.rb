require 'cfndsl/jsonable'

module CfnDsl
  # Handles creation policy objects for Resources
  #
  # Usage
  #   Resource("aaa") {
  #     CreationPolicy('ResourceSignal', { 'Count' => 1,  'Timeout' => 'PT10M' })
  #   }
  class CreationPolicyDefinition < JSONable
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_json(*a)
      @value.to_json(*a)
    end
  end
end
