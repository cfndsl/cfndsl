# frozen_string_literal: true

require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  context 'generated_refs for transform-created resources' do
    it 'allows referencing resources declared with generated_refs' do
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

        # Declare resources that SAM will generate
        generated_refs :myfuncAliaslive, /myfuncVersion[a-f0-9]+/
      end

      # Lambda Permission referencing the auto-created alias
      template.Lambda_Permission(:myfuncpermission) do
        DependsOn :myfuncAliaslive
        Action 'lambda:InvokeFunction'
        FunctionName FnJoin('', [Ref(:myfunc), ':live'])
        Principal 'apigateway.amazonaws.com'
      end

      # This should not raise an error
      expect { template.validate }.not_to raise_error
    end

    it 'allows regex patterns for generated refs' do
      template.Serverless_Function(:testfunc) do
        Handler 'index.handler'
        Runtime 'nodejs22.x'
        CodeUri './functions/testfunc'
        AutoPublishAlias 'prod'

        # Use regex for version resources with unpredictable hash
        generated_refs(/testfuncVersion[a-f0-9]+/)
      end

      # Reference to auto-created version (with mock hash)
      template.Lambda_Permission(:versionpermission) do
        DependsOn :testfuncVersionabcd1234
        Action 'lambda:InvokeFunction'
        FunctionName Ref(:testfunc)
        Principal 'apigateway.amazonaws.com'
      end

      # This should not raise an error
      expect { template.validate }.not_to raise_error
    end

    it 'still validates invalid references' do
      template.Serverless_Function(:validfunc) do
        Handler 'index.handler'
        Runtime 'nodejs22.x'
        CodeUri './functions/validfunc'
        AutoPublishAlias 'live'
        generated_refs :validfuncAliaslive
      end

      # Reference to a completely invalid resource
      template.Lambda_Permission(:invalidpermission) do
        DependsOn :nonexistentresource
        Action 'lambda:InvokeFunction'
        FunctionName Ref(:validfunc)
        Principal 'apigateway.amazonaws.com'
      end

      # This should still raise an error
      expect { template.validate }.to raise_error(CfnDsl::Error, /Invalid Reference.*nonexistentresource/)
    end

    it 'does not allow undeclared generated refs' do
      template.Serverless_Function(:nopublishfunc) do
        Handler 'index.handler'
        Runtime 'nodejs22.x'
        CodeUri './functions/nopublishfunc'
        # No AutoPublishAlias, no generated_refs
      end

      # Reference to alias that won't be created and wasn't declared
      template.Lambda_Permission(:invalidalias) do
        DependsOn :nopublishfuncAliaslive
        Action 'lambda:InvokeFunction'
        FunctionName Ref(:nopublishfunc)
        Principal 'apigateway.amazonaws.com'
      end

      # This should raise an error
      expect { template.validate }.to raise_error(CfnDsl::Error, /Invalid Reference.*nopublishfuncAliaslive/)
    end
  end
end
