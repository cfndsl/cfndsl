require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  describe '#KMS_Alias' do
    it 'supports AliasName property' do
      template.KMS_Alias(:Test) do
        AliasName 'test-key'
      end

      expect(template.to_json).to include('"AliasName":"test-key"')
    end

    it 'supports TargetKeyId property' do
      template.KMS_Alias(:Test) do
        TargetKeyId 'kms-key-123'
      end

      expect(template.to_json).to include('"TargetKeyId":"kms-key-123"')
    end
  end
end
