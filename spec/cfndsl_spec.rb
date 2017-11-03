require 'spec_helper'

describe CfnDsl do
  let(:test_template_file_name) { "#{File.dirname(__FILE__)}/fixtures/test.rb" }
  let(:heat_test_template_file_name) { "#{File.dirname(__FILE__)}/fixtures/heattest.rb" }

  after(:example) { CfnDsl::ExternalParameters.refresh! }

  it 'evaluates a cloud formation' do
    subject.eval_file_with_extras(test_template_file_name, [[:raw, 'test=123']])
  end

  it 'evaluates a heat' do
    subject.eval_file_with_extras(heat_test_template_file_name)
  end

  context 'when binding is disabed' do
    let(:param_value) { 'www.google.com?a=1&b=2' }
    before do
      CfnDsl.disable_binding
    end

    it 'evaluates parameters correctly when its value contains "="' do
      template = subject.eval_file_with_extras(test_template_file_name, [[:raw, "three=#{param_value}"]]).to_json
      parsed_template = JSON.parse(template)
      expect(parsed_template['Parameters']['Three']['Default']).to eq param_value
    end
  end
end

describe CfnDsl::HeatTemplate do
  it 'honors last-set value for non-array properties' do
    spec = self
    subject.declare do
      Server('myserver') do
        flavor 'foo'
        flavor 'bar'
        f = @Properties['flavor'].value
        spec.expect(f).to spec.eq('bar')
      end
    end
  end
end

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
    q = subject.Resource('q') { DependsOn ['r'] }
    r = subject.Resource('r') { Property('z', Ref('q')) }
    q_refs = q.build_references({})
    r_refs = r.build_references({})
    expect(q_refs).to have_key('r')
    expect(q_refs).to_not have_key('q')
    expect(r_refs).to have_key('q')
    expect(r_refs).to_not have_key('r')
    expect(subject.check_refs.length).to eq(2)
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
        spec.expect(groups).to spec.eq(%w[one two])
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

    expect(result2).to be_a(CfnDsl::AWS::Types::AWSIAMUserPolicy)
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
      refs = ref.build_references({})
      expect(refs).to have_key(param)
    end
  end

  it 'honors last-set value for non-array properties' do
    spec = self
    subject.declare do
      EC2_Instance('myserver') do
        InstanceType 'foo'
        InstanceType 'bar'
        f = @Properties['InstanceType'].value
        spec.expect(f).to spec.eq('bar')
      end
    end
  end

  context 'built-in functions' do
    it 'FnGetAtt' do
      func = subject.FnGetAtt('A', 'B')
      expect(func.to_json).to eq('{"Fn::GetAtt":["A","B"]}')
    end

    it 'FnJoin' do
      func = subject.FnJoin('A', %w[B C])
      expect(func.to_json).to eq('{"Fn::Join":["A",["B","C"]]}')
    end

    it 'FnSplit' do
      func = subject.FnSplit('|', 'a|b|c')
      expect(func.to_json).to eq('{"Fn::Split":["|","a|b|c"]}')
    end

    it 'Ref' do
      ref = subject.Ref 'X'
      expect(ref.to_json).to eq('{"Ref":"X"}')
      refs = ref.build_references({})
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

    context 'FnImportValue' do
      it 'formats correctly' do
        func = subject.FnImportValue 'ExternalResource'
        expect(func.to_json).to eq('{"Fn::ImportValue":"ExternalResource"}')
      end
    end

    context 'FnNot', 'Array' do
      it 'FnNot' do
        func = subject.FnNot(['foo'])
        expect(func.to_json).to eq('{"Fn::Not":["foo"]}')
      end
    end

    context 'FnNot', 'String' do
      it 'FnNot' do
        func = subject.FnNot('foo')
        expect(func.to_json).to eq('{"Fn::Not":["foo"]}')
      end
    end

    context 'FnSub', 'String' do
      it 'formats correctly' do
        func = subject.FnSub('http://aws.${AWS::Region}.com')
        expect(func.to_json).to eq('{"Fn::Sub":"http://aws.${AWS::Region}.com"}')
      end

      it 'raises an error if not given a string' do
        expect { subject.FnSub(1234) }.to raise_error(ArgumentError)
      end
    end

    context 'FnSub', 'Hash' do
      it 'formats correctly' do
        func = subject.FnSub('http://aws.${domain}.com', domain: 'foo')
        expect(func.to_json).to eq('{"Fn::Sub":["http://aws.${domain}.com",{"domain":"foo"}]}')
      end

      it 'raises an error if not given a second argument that is not a Hash' do
        expect { subject.FnSub('abc', 123) }.to raise_error(ArgumentError)
      end
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
        multiline = <<-TEXT.gsub(/^ {10}/, '')
          This is the first line
          This is the %0 line
          This is a %% sign
        TEXT
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
