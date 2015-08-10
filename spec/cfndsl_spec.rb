require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do

  it 'populates an empty template' do
    expect(subject.to_json).to eq('{"AWSTemplateFormatVersion":"2010-09-09"}')
  end

  it 'allows the format version to be set' do
    subject.AWSTemplateFormatVersion 'AAAAAA'
    expect(subject.to_json).to eq('{"AWSTemplateFormatVersion":"AAAAAA"}')
  end

  it 'sets output values' do
    out = subject.Output(:Out) do
      Value 'value'
      Description 'desc'
    end
    spec = self
    out.declare do
      spec.expect(@Value).to spec.eq('value')
      spec.expect(@Description).to spec.eq('desc')
    end
    subject.declare do
      spec.expect(@Outputs.length).to spec.eq(1)
    end
  end

  it 'validates references' do
    q = subject.Resource('q'){ DependsOn ['r'] }
    r = subject.Resource('r'){ Property('z', Ref('q')) }
    q_refs = q.references Hash.new
    r_refs = r.references Hash.new
    expect(q_refs).to have_key('r')
    expect(q_refs).to_not have_key('q')
    expect(r_refs).to have_key('q')
    expect(r_refs).to_not have_key('r')
    expect(subject.checkRefs.length).to eq(2)
  end

  it 'is a data-driven language' do
    spec = self
    subject.declare do
      EC2_Instance('Instance') do
        id = ImageId 'aaaaa'
        SecurityGroup 'one'
        SecurityGroup 'two'
        groups = @Properties['SecurityGroups'].value
        spec.expect(id).to spec.eq('aaaaa')
        spec.expect(groups).to spec.eq(['one', 'two'])
      end
    end
  end

  it 'singularizes indirectly' do
    user = subject.User 'TestUser'
    policy = user.Policy 'stuff'
    expect(policy).to eq('stuff')

    result2 = user.Policy do
      PolicyName 'stuff'
      PolicyDocument(a: 7)
    end

    expect(result2).to be_a(CfnDsl::AWSTypes::IAMEmbeddedPolicy)
    expect(user.instance_variable_get('@Properties')['Policies'].value.length).to eq(2)
  end

  it 'handles pseudo parameters' do
    [
      'AWS::AccountId',
      'AWS::NotificationARNs',
      'AWS::NoValue',
      'AWS::Region',
      'AWS::StackId',
      'AWS::StackName'
    ].each do |param|
      ref = subject.Ref param
      expect(ref.to_json).to eq("{\"Ref\":\"#{param}\"}")
      refs = ref.references({})
      expect(refs).to have_key(param)
    end
  end

  context 'built-in functions' do
    it 'FnGetAtt' do
      func = subject.FnGetAtt('A', 'B')
      expect(func.to_json).to eq('{"Fn::GetAtt":["A","B"]}')
    end

    it 'FnJoin' do
      func = subject.FnJoin('A', ['B', 'C'])
      expect(func.to_json).to eq('{"Fn::Join":["A",["B","C"]]}')
    end

    it 'Ref' do
      ref = subject.Ref 'X'
      expect(ref.to_json).to eq('{"Ref":"X"}')
      refs = ref.references Hash.new
      expect(refs).to have_key('X')
    end

    it 'FnBase64' do
      func = subject.FnBase64 'A'
      expect(func.to_json).to eq('{"Fn::Base64":"A"}')
    end

    it 'FnFindInMap' do
      func = subject.FnFindInMap('map', 'key', 'value')
      expect(func.to_json).to eq('{"Fn::FindInMap":["map","key","value"]}')
    end

    it 'FnGetAZs' do
      func = subject.FnGetAZs 'reg'
      expect(func.to_json).to eq('{"Fn::GetAZs":"reg"}')
    end

    context 'FnFormat', 'String' do
      it 'formats correctly' do
        func = subject.FnFormat('abc%0def%1ghi%%x', 'A', 'B')
        expect(func.to_json).to eq('{"Fn::Join":["",["abc","A","def","B","ghi","%","x"]]}')
      end
    end

    context 'FnFormat', 'Hash' do
      it 'formats correctly' do
        func = subject.FnFormat('abc%{first}def%{second}ghi%%x', first: 'A', second: 'B')
        expect(func.to_json).to eq('{"Fn::Join":["",["abc","A","def","B","ghi","%","x"]]}')
      end
    end

    context 'FnFormat', 'Multiline' do
      it 'formats correctly' do
        multiline = <<-EOF.gsub(/^ {10}/, '')
          This is the first line
          This is the %0 line
          This is a %% sign
        EOF
        func = subject.FnFormat(multiline, 'second')
        expect(func.to_json).to eq('{"Fn::Join":["",["This is the first line\nThis is the ","second"," line\nThis is a ","%"," sign\n"]]}')
      end
    end

    context 'FnFormat', 'Ref' do
      it 'formats correctly' do
        func = subject.FnFormat '123%{Test}456'
        expect(func.to_json).to eq('{"Fn::Join":["",["123",{"Ref":"Test"},"456"]]}')
      end
    end
  end
end
