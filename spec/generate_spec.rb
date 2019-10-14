# rubocop:disable Style/FrozenStringLiteralComment
require 'spec_helper'
describe Cfnlego do
  let(:template) { Cfnlego.run(resources: ['AWS::EC2::EIP,EIP']) }

  context '#Export' do
    it 'formats correctly' do
      output = "require 'cfndsl'\nCloudFormation do\n  Description 'auto generated cloudformation cfndsl template'\n\n "
      output << " EC2_EIP('EIP') do\n    Domain String "
      output << '# http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-eip.html#cfn-ec2-eip-domain'
      output << "\n    InstanceId String # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-eip.html#cfn-ec2-eip-instanceid"
      output << "\n    PublicIpv4Pool String # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-eip.html#cfn-ec2-eip-publicipv4pool"
      output << "\n  end\nend\n"
      expect(template).to eq output
    end
  end
end
# rubocop:enable Style/FrozenStringLiteralComment
