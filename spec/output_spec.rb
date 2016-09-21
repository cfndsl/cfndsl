require 'spec_helper'

describe CfnDsl::OutputDefinition do
  let(:template) { CfnDsl::OrchestrationTemplate.new }

  context '#Export' do
    it 'formats correctly' do
      output = template.Output(:testOutput) do
        Value 'stuff'
        Export 'publishedValue'
      end
      expect(output.to_json).to eq('{"Value":"stuff","Export":{"Name":"publishedValue"}}')
    end
  end
end
