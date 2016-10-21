require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  describe "#ECS_TaskDefinition" do
    it 'supports TaskRoleArn property' do
      template.ECS_TaskDefinition(:Test) do
        TaskRoleArn 'arn:aws:iam::123456789012:role/S3Access'
      end

      expect(template.to_json).to include('"TaskRoleArn":"arn:aws:iam::123456789012:role/S3Access"')
    end

    it 'supports Family property' do
      template.ECS_TaskDefinition(:Test) do
        Family 'Fam'
      end

      expect(template.to_json).to include('"Family":"Fam"')
    end
  end
end
