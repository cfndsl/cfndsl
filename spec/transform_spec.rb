require 'spec_helper'

describe 'Transform' do
  let(:template) { CfnDsl::OrchestrationTemplate.new }

  it 'is settable for a template' do
    template.Transform('AWS::Serverless-2016-10-31')
    expect(template.to_json).to match(/"Transform":"AWS::Serverless-2016-10-31"/)
  end
end
