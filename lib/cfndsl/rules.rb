# frozen_string_literal: true

require 'cfndsl/jsonable'

module CfnDsl
  # Handles Rule objects
  class RuleDefinition < JSONable
    dsl_attr_setter :RuleCondition, :Assertions

    def initialize
      @Assertions = []
    end

    def Assert(desc, struct)
      @Assertions.push('Assert' => struct, 'AssertDescription' => desc)
    end

    def FnContains(list_of_strings, string)
      Fn.new('Contains', [list_of_strings, string])
    end

    def FnEachMemberEquals(list_of_strings, string)
      Fn.new('EachMemberEquals', [list_of_strings, string])
    end

    def FnEachMemberIn(strings_to_check, strings_to_match)
      Fn.new('EachMemberIn', [strings_to_check, strings_to_match])
    end

    def FnRefAll(parameter_type)
      Fn.new('RefAll', parameter_type)
    end

    def FnValueOf(parameter_logical_id, attribute)
      raise 'Cannot use functions within FnValueOf' unless parameter_logical_id.is_a?(String) && attribute.is_a?(String)

      Fn.new('ValueOf', [parameter_logical_id, attribute])
    end

    def FnValueOfAll(parameter_logical_id, attribute)
      raise 'Cannot use functions within FnValueOfAll' unless parameter_logical_id.is_a?(String) && attribute.is_a?(String)

      Fn.new('ValueOfAll', [parameter_logical_id, attribute])
    end
  end
end
