require 'spec_helper'

describe CfnDsl::ResourceDefinition do
  subject { CfnDsl::CloudFormationTemplate.new.EC2_Instance(:web_server) }

  context '#addTag' do
    it 'is a pass-through method to add_tag' do
      expect(subject).to receive(:add_tag).with('role', 'web-server')
      subject.addTag('role', 'web-server')
    end
  end

  context '#add_tag' do
    it 'adds a Tag for the resource' do
      subject.add_tag('role', 'web-server')
      tags = subject.Property(:Tags).value
      expect(tags).to be_an(Array)
      tag = tags.pop
      expect(tag.instance_variable_get('@Key')).to eq('role')
      expect(tag.instance_variable_get('@Value')).to eq('web-server')
    end
  end
end
