require 'spec_helper'

describe CfnDsl::ResourceDefinition do
  subject { CfnDsl::CloudFormationTemplate.new.Resource(:single_server) }
  context '#ResourceTypeEC2' do
    it 'checks that the type is AWS::EC2::Instance' do
      subject.Type('AWS::EC2::Instance')
      expect(subject.instance_variable_get('@Type')).to eq('AWS::EC2::Instance')
    end
  end
end

describe CfnDsl::ResourceDefinition do
  subject { CfnDsl::CloudFormationTemplate.new.AutoScalingGroup(:web_servers) }
  context '#ResourceTypeASG' do
    it 'checks that the type is AWS::AutoScaling::AutoScalingGroup' do
      expect(subject.instance_variable_get('@Type')).to eq('AWS::AutoScaling::AutoScalingGroup')
    end
  end
  context '#addTag' do
    it 'is a pass-through method to add_tag' do
      expect(subject).to receive(:add_tag).with('role', 'web-server', true)
      subject.addTag('role', 'web-server', true)
    end
  end

  context '#add_tag' do
    it 'adds a Tag for the resource' do
      subject.add_tag('role', 'web-server', true)
      tags = subject.Property(:Tags).value
      expect(tags).to be_an(Array)
      tag = tags.pop
      expect(tag.instance_variable_get('@Key')).to eq('role')
      expect(tag.instance_variable_get('@Value')).to eq('web-server')
      expect(tag.instance_variable_get('@PropagateAtLaunch')).to eq(true)
    end
  end
end
