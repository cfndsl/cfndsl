# frozen_string_literal: true

require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  context 'Serverless_Function with AutoPublishAlias' do
    it 'allows referencing auto-created alias resources' do
      template.Parameter(:lambdaexecutionrole) do
        Type 'String'
        Description 'Lambda Execution Role ARN'
      end

      # Lambda Function with AutoPublishAlias
      template.Serverless_Function(:myfunc) do
        Handler 'index.handler'
        Runtime 'nodejs22.x'
        CodeUri './functions/myfunc'
        Role Ref(:lambdaexecutionrole)
        Timeout 3
        AutoPublishAlias 'live'
      end

      # Lambda Permission referencing the auto-created alias
      template.Lambda_Permission(:myfuncpermission) do
        DependsOn :myfuncAliaslive # This should be valid now
        Action 'lambda:InvokeFunction'
        FunctionName FnJoin('', [Ref(:myfunc), ':live'])
        Principal 'apigateway.amazonaws.com'
      end

      # This should not raise an error
      expect { template.validate }.not_to raise_error
    end

    it 'allows referencing auto-created version resources' do
      template.Serverless_Function(:testfunc) do
        Handler 'index.handler'
        Runtime 'nodejs22.x'
        CodeUri './functions/testfunc'
        AutoPublishAlias 'prod'
      end

      # Reference to auto-created version (with mock hash)
      template.Lambda_Permission(:versionpermission) do
        DependsOn :testfuncVersionabcd1234 # Mock version resource name
        Action 'lambda:InvokeFunction'
        FunctionName Ref(:testfunc)
        Principal 'apigateway.amazonaws.com'
      end

      # This should not raise an error
      expect { template.validate }.not_to raise_error
    end

    it 'still validates invalid references for non-SAM resources' do
      template.Serverless_Function(:validfunc) do
        Handler 'index.handler'
        Runtime 'nodejs22.x'
        CodeUri './functions/validfunc'
        AutoPublishAlias 'live'
      end

      # Reference to a completely invalid resource
      template.Lambda_Permission(:invalidpermission) do
        DependsOn :nonexistentresource # This should still fail
        Action 'lambda:InvokeFunction'
        FunctionName Ref(:validfunc)
        Principal 'apigateway.amazonaws.com'
      end

      # This should still raise an error
      expect { template.validate }.to raise_error(CfnDsl::Error, /Invalid Reference.*nonexistentresource/)
    end

    it 'does not allow alias references for functions without AutoPublishAlias' do
      template.Serverless_Function(:nopublishfunc) do
        Handler 'index.handler'
        Runtime 'nodejs22.x'
        CodeUri './functions/nopublishfunc'
        # No AutoPublishAlias
      end

      # Reference to alias that won't be created
      template.Lambda_Permission(:invalidalias) do
        DependsOn :nopublishfuncAliaslive # This should fail
        Action 'lambda:InvokeFunction'
        FunctionName Ref(:nopublishfunc)
        Principal 'apigateway.amazonaws.com'
      end

      # This should raise an error
      expect { template.validate }.to raise_error(CfnDsl::Error, /Invalid Reference.*nopublishfuncAliaslive/)
    end
  end
end
