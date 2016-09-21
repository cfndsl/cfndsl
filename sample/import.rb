CloudFormation do
  EC2_SecurityGroup(:databaseSecurityGroup) do
    GroupDescription 'Allow access from only web instances'
    SecurityGroupIngress [
      {
        'SourceSecurityGroupId' => FnImportValue(:webSecurityGroupId),
        'IpProtocol' => 'tcp',
        'FromPort'   => 7777,
        'ToPort'     => 7777,
      }
    ]
  end

  EC2_Instance(:databaseInstance) do
    ImageId        'ami-59e8964e'
    InstanceType   'm3.large'
    SecurityGroups [Ref(:databaseSecurityGroup)]
  end
end
