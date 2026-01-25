# frozen_string_literal: true

# Ruby patch for AWS::Serverless::Function AutoPublishAlias property
# Automatically adds generated_refs for Alias and Version resources created by SAM transform

module CfnDsl
  module AWS
    # rubocop:disable Style/Documentation
    module Types
      # Monkey-patch the generated AWS::Serverless::Function class
      AWS_Serverless_Function.class_eval do
        # Override auto_generated_refs to detect AutoPublishAlias and add patterns
        def auto_generated_refs
          refs = []

          # When AutoPublishAlias is specified, SAM generates:
          # - AWS::Lambda::Alias with LogicalId: <FunctionName>Alias<AliasName>
          # - AWS::Lambda::Version with LogicalId: <FunctionName>Version<hash>
          # See: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-specification-generated-resources-function.html
          if @Properties&.include?('AutoPublishAlias')
            # Use permissive regex to handle both literal values and dynamic refs (Ref, FnSub, etc.)
            refs << /#{@_LogicalName}Alias.+/
            refs << /#{@_LogicalName}Version[a-f0-9]+/
          end

          refs
        end
      end
    end
    # rubocop:enable Style/Documentation
  end
end
