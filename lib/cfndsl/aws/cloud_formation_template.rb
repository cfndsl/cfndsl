require 'cfndsl/orchestration_template'

module CfnDsl
  # Cloud Formation Templates
  class CloudFormationTemplate < OrchestrationTemplate
    def self.template_types
      CfnDsl::AWS::Types::Types_Internal
    end

    def self.type_module
      CfnDsl::AWS::Types
    end

    create_types
  end
end
