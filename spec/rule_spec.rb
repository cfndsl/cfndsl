# frozen_string_literal: true

require 'spec_helper'

describe CfnDsl::RuleDefinition do
  let(:template) { CfnDsl::OrchestrationTemplate.new }
  let(:target) { File.read("#{File.dirname(__FILE__)}/fixtures/rule-assertion.json") }
  context '#Assert' do
    it 'formats correctly' do
      output = template.Rule(:testRule) do
        Assert('x', FnEachMemberIn(FnValueOfAll('a', 'b'), FnRefAll('c')))
        RuleCondition FnEquals(Ref('y'), 'z')
      end
      expect(output.to_json).to eq(target)
    end
  end
end
