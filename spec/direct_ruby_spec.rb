# frozen_string_literal: true

require 'spec_helper'

class TemplateBuilder
  include CfnDsl::CloudFormation
end

describe TemplateBuilder do
  it 'includes Functions' do
    expect(subject.FnSub('Substitution')).to be_an_instance_of(CfnDsl::Fn)
  end

  context('#CloudFormation') do
    it 'returns a CloudFormationTemplate' do
      expect(subject.CloudFormation('A Template')).to be_an_instance_of(CfnDsl::CloudFormationTemplate)
    end
  end
end
