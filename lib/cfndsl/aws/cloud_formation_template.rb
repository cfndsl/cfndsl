# frozen_string_literal: true

require_relative '../orchestration_template'
require_relative 'types'

module CfnDsl
  # Cloud Formation Templates
  class CloudFormationTemplate < OrchestrationTemplate
    def self.template_types
      CfnDsl::AWS::Types::Types_Internal
    end

    def self.type_module
      CfnDsl::AWS::Types
    end

    def self.check_types(file: nil, version: nil)
      version = Gem::Version.new(version || '0.0.0') unless version.is_a?(Gem::Version)
      raise Error, "CfnDsl Types and Resources loaded from #{template_types['File']}, expected #{file}" if file && file != template_types['File']
      raise Error, "CfnDsl Types and Resources version #{template_types['Version']}, expected at least #{version}" if template_types['Version'] < version
    end

    create_types
  end
end
