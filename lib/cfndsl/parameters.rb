require 'cfndsl/jsonable'

module CfnDsl
  # Handles input parameter objects
  class ParameterDefinition < JSONable
    dsl_attr_setter :Type, :Default, :NoEcho, :AllowedValues, :AllowedPattern, :MaxLength,
                    :MinLength, :MaxValue, :MinValue, :Description, :ConstraintDescription

    def initialize
      @Type = :String
    end

    def String
      @Type = :String
    end

    def Number
      @Type = :Number
    end

    def CommaDelimitedList
      @Type = :CommaDelimitedList
    end

    def to_hash
      h = {}
      h[:Type] = @Type
      h[:Default] = @Default if @Default
    end
  end
end
