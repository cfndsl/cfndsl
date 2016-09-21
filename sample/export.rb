CloudFormation do
  EC2_SecurityGroup(:webSecurityGroup) do
    GroupDescription 'Allow incoming HTTP traffic from anywhere'
    SecurityGroupIngress [
      {
        'CidrIp'     => '0.0.0.0/0',
        'IpProtocol' => 'tcp',
        'FromPort'   => 80,
        'ToPort'     => 80,
      }
    ]
  end

  EC2_Instance(:webInstance) do
    ImageId      'ami-59e8964e'
    InstanceType 'm3.large'
    SecurityGroups [Ref(:webSecurityGroup)]
  end

  Output(:securityGroupId) do
    Value FnGetAtt(:webSecurityGroup, :GroupId)
    Export :webSecurityGroupId
  end
end
