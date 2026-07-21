# frozen_string_literal: true

require 'spec_helper'

describe 'AWS::Serverless::Function AutoPublishAlias auto-generated refs' do
  let(:template) { CfnDsl::CloudFormationTemplate.new }

  context 'with literal AutoPublishAlias value' do
    it 'automatically validates references to generated Alias and Version resources' do
      template.declare do
        Serverless_Function(:MyFunction) do
          Runtime 'python3.9'
          Handler 'index.handler'
          CodeUri 's3://bucket/key'
          AutoPublishAlias 'live'
        end

        EC2_Instance(:MyInstance) do
          ImageId 'ami-12345678'
          UserData FnGetAtt('MyFunctionAliaslive', 'FunctionArn')
        end

        Output(:VersionArn) do
          Value FnGetAtt('MyFunctionVersion1234abcd', 'Arn')
        end
      end

      expect(template.validate).to be_truthy
    end
  end

  context 'with Ref() AutoPublishAlias value' do
    it 'automatically validates references to generated resources with dynamic names' do
      template.declare do
        Parameter(:AliasName) do
          Type 'String'
          Default 'live'
        end

        Serverless_Function(:MyFunction) do
          Runtime 'python3.9'
          Handler 'index.handler'
          CodeUri 's3://bucket/key'
          AutoPublishAlias Ref('AliasName')
        end

        Output(:AliasArn) do
          Value FnGetAtt('MyFunctionAliasprod', 'FunctionArn')
        end
      end

      expect(template.validate).to be_truthy
    end
  end

  context 'with manual generated_refs' do
    it 'combines auto-generated refs with user-supplied refs (additive)' do
      template.declare do
        Serverless_Function(:MyFunction) do
          Runtime 'python3.9'
          Handler 'index.handler'
          CodeUri 's3://bucket/key'
          AutoPublishAlias 'live'
          # User adds additional generated refs
          generated_refs :MyFunctionCustomResource
        end

        # Reference auto-generated resource
        Output(:AliasArn) do
          Value FnGetAtt('MyFunctionAliaslive', 'FunctionArn')
        end

        # Reference user-declared generated resource
        Output(:CustomArn) do
          Value FnGetAtt('MyFunctionCustomResource', 'Arn')
        end
      end

      expect(template.validate).to be_truthy
    end
  end

  context 'without AutoPublishAlias' do
    it 'does not validate references to non-existent generated resources' do
      template.declare do
        Serverless_Function(:MyFunction) do
          Runtime 'python3.9'
          Handler 'index.handler'
          CodeUri 's3://bucket/key'
          # No AutoPublishAlias
        end

        Output(:AliasArn) do
          Value FnGetAtt('MyFunctionAliaslive', 'FunctionArn')
        end
      end

      expect { template.validate }.to raise_error(CfnDsl::Error, /Invalid Reference.*MyFunctionAliaslive/)
    end
  end

  context 'non-SAM resources' do
    it 'are unaffected by SAM patches' do
      template.declare do
        EC2_Instance(:MyInstance) do
          ImageId 'ami-12345678'
        end

        Output(:InstanceId) do
          Value Ref('MyInstance')
        end
      end

      expect(template.validate).to be_truthy
    end
  end

  context 'multiple functions with AutoPublishAlias' do
    it 'correctly scopes generated refs to each function' do
      template.declare do
        Serverless_Function(:FunctionA) do
          Runtime 'python3.9'
          Handler 'index.handler'
          CodeUri 's3://bucket/key'
          AutoPublishAlias 'live'
        end

        Serverless_Function(:FunctionB) do
          Runtime 'nodejs18.x'
          Handler 'index.handler'
          CodeUri 's3://bucket/key'
          AutoPublishAlias 'prod'
        end

        Output(:AliasA) do
          Value FnGetAtt('FunctionAAliaslive', 'FunctionArn')
        end

        Output(:AliasB) do
          Value FnGetAtt('FunctionBAliasp rod', 'FunctionArn')
        end

        Output(:VersionA) do
          Value FnGetAtt('FunctionAVersion1234abcd', 'Arn')
        end
      end

      expect(template.validate).to be_truthy
    end
  end
end
