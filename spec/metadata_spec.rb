# frozen_string_literal: true

require 'spec_helper'

describe 'Metadata' do
  let(:template) { CfnDsl::CloudformationTemplate.new }

  it 'is settable for a template' do
    template.Metadata(foo: 'bar')
    expect(template.to_json).to match(/"Metadata":{"foo":"bar"}/)
  end

  it 'is settable for a resource' do
    resource = template.Resource(:foo) { Metadata(foo: 'bar') }
    expect(resource.to_json).to match(/"Metadata":{"foo":"bar"}/)
  end
end
