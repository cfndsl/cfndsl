require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  describe '#IAM_ManagedPolicy' do
    it 'supports ManagedPolicyName property' do
      template.IAM_ManagedPolicy(:TestPolicy) do
        ManagedPolicyName 'test-policy'
      end

      expect(template.to_json).to include('"ManagedPolicyName":"test-policy"')
    end
  end
end
