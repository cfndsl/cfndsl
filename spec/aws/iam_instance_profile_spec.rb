require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  describe '#IAM_InstanceProfile' do
    it 'supports InstanceProfileName property' do
      template.IAM_InstanceProfile(:TestPolicy) do
        InstanceProfileName 'instance-profile-name'
      end

      expect(template.to_json).to include('"InstanceProfileName":"instance-profile-name"')
    end
  end
end
