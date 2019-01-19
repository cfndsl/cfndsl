# frozen_string_literal: true

shared_examples 'an orchestration template' do
  context '#initialize with block' do
    subject do
      described_class.new { Resource(:foo) { Type :bar } }
    end

    it 'evaluates the block' do
      resources = subject.instance_variable_get('@Resources')
      expect(resources).to_not be_empty
      foo = resources.first[1]
      expect(foo.instance_variable_get('@Type')).to eql(:bar)
    end
  end

  context '#valid_ref?' do
    it 'returns true if ref is global' do
      expect(subject.valid_ref?('AWS::Region')).to eq(true)
    end

    it 'returns true if ref is a parameter' do
      subject.Parameter(:foo)
      expect(subject.valid_ref?(:foo)).to eq(true)
    end
  end

  context '#check_refs' do
    it 'returns an array of invalid refs if present' do
      subject.EC2_Instance(:foo) { UserData Ref(:bar) }
      expect(subject.check_refs).to_not be_empty
    end

    it 'returns nil if no invalid refs are present' do
      subject.EC2_Instance(:foo) { UserData Ref('AWS::Region') }
      expect(subject.check_refs).to eq(nil)
    end
  end

  context '#check_resource_refs' do
    it 'returns an array with an error message if invalid refs are present' do
      subject.EC2_Instance(:foo) { UserData Ref(:bar) }
      expect(subject.check_resource_refs).to eq(['Invalid Reference: Resource foo refers to bar'])
    end

    it 'returns an empty array ' do
      subject.EC2_Instance(:foo) { UserData Ref('AWS::AccountId') }
      expect(subject.check_resource_refs).to eq([])
    end
  end

  context '#check_output_refs' do
    it 'returns an array with an error message if invalid refs are present' do
      subject.EC2_Instance(:foo)
      subject.Output(:baz) { Value Ref(:bar) }
      expect(subject.check_output_refs).to eq(['Invalid Reference: Output baz refers to bar'])
    end

    it 'returns an empty array' do
      subject.EC2_Instance(:foo)
      subject.Output(:baz) { Value Ref(:foo) }
      expect(subject.check_output_refs).to eq([])
    end
  end

  context '.create_types' do
    it 'creates a type class for each entry' do
      expect(described_class.type_module).to be_const_defined('AWS_EC2_Instance')
      expect(described_class.type_module.const_get('AWS_EC2_Instance')).to be < CfnDsl::ResourceDefinition
    end

    it 'defines case-insensitive properties for each type class' do
      ec2_instance = described_class.type_module.const_get('AWS_EC2_Instance').new
      expect(ec2_instance).to respond_to(:imageId)
      expect(ec2_instance).to respond_to(:ImageId)
    end

    it 'defines singular and plural methods for array properties' do
      ec2_instance = described_class.type_module.const_get('AWS_EC2_Instance').new
      ec2_instance.SecurityGroup(foo: 'bar')
      singular_value = ec2_instance.instance_variable_get('@Properties')['SecurityGroups'].value
      expect(singular_value).to eq([{ foo: 'bar' }])
      ec2_instance = described_class.type_module.const_get('AWS_EC2_Instance').new
      ec2_instance.SecurityGroups([{ foo: 'bar' }])
      plural_value = ec2_instance.instance_variable_get('@Properties')['SecurityGroups'].value
      expect(plural_value).to eq([{ foo: 'bar' }])
    end

    it 'defines accessor methods for each of the entries' do
      expect(subject).to respond_to(:AWS_EC2_Instance)
      expect(subject).to respond_to(:EC2_Instance)
    end

    it 'avoids ambiguous accessor methods' do
      expect(subject).to_not respond_to(:Instance)
    end

    it 'avoids duplicating singular and plural methods' do
      security_group = described_class.type_module.const_get('AWS_EC2_SecurityGroup').new
      security_group.SecurityGroupIngress([{ foo: 'bar' }])
      plural_value = security_group.instance_variable_get('@Properties')['SecurityGroupIngress'].value
      expect(plural_value).to eq([{ foo: 'bar' }])
    end

    it 'sets the type of each resource correctly' do
      ec2_instance = subject.EC2_Instance(:foo)
      expect(ec2_instance.instance_variable_get('@Type')).to eq('AWS::EC2::Instance')
      ec2_instance = subject.Resource(:bar) { Type 'AWS::EC2::Instance' }
      expect(ec2_instance.instance_variable_get('@Type')).to eq('AWS::EC2::Instance')
    end
  end
end
