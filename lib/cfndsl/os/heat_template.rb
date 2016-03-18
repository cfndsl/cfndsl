require 'cfndsl/orchestration_template'

module CfnDsl
  class HeatTemplate < OrchestrationTemplate
    def self.template_types
      CfnDsl::OS::Types::Types_Internal
    end

    def self.type_module
      CfnDsl::OS::Types
    end

    create_types
  end
end
