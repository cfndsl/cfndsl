require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  describe '#EC2_SecurityGroup' do
    it 'supports GroupName property' do
      template.EC2_SecurityGroup(:Test) do
        GroupName 'super-group'
      end

      expect(template.to_json).to include('"GroupName":"super-group"')
    end
  end
end
