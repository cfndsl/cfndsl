# frozen_string_literal: false

require 'spec_helper'

describe Cfnlego do
  let(:template) { Cfnlego.run(resources: ['AWS::EC2::EIP,EIP']) }

  context '#Export' do
    it 'formats correctly' do
      output = "require 'cfndsl'\nCloudFormation do\n  Description 'auto generated cloudformation cfndsl template'\n\n "
      output << " EC2_EIP('EIP') do"
      output << "\n    InstanceId String # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-eip.html#cfn-ec2-eip-instanceid"
      output << "\n    PublicIpv4Pool String # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-eip.html#cfn-ec2-eip-publicipv4pool"
      output << "\n    TransferAddress String # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-eip.html#cfn-ec2-eip-transferaddress"
      output << "\n    Domain String # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-eip.html#cfn-ec2-eip-domain"
      output << "\n    Tags [List] # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-eip.html#cfn-ec2-eip-tags"
      output << "\n    NetworkBorderGroup String # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-eip.html#cfn-ec2-eip-networkbordergroup"
      output << "\n  end\nend\n"
      expect(template).to eq output
    end
  end
end
