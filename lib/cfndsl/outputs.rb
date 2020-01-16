# frozen_string_literal: true

require_relative 'jsonable'

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

    def condition_refs
      [@Condition].flatten.compact.map(&:to_s)
    end
  end
end
