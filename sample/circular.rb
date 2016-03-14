CloudFormation do
  AWSTemplateFormatVersion '2010-09-09'

  Description 'Circular Reference'

  Parameter('InstanceType') do
    Description 'Type of EC2 instance to launch'
    Type 'String'
    Default 'm1.small'
  end

  Resource('WebServerGroup') do
    Type 'AWS::AutoScaling::AutoScalingGroup'
    Property('AvailabilityZones', FnGetAZs(''))
    Property('LaunchConfigurationName', Ref('LaunchConfig'))
    Property('MinSize', '1')
    Property('MaxSize', '3')
  end

  Resource('LaunchConfig') do
    Type 'AWS::AutoScaling::LaunchConfiguration'
    DependsOn ['WebServerGroup']
    Property('InstanceType', Ref('InstanceType'))
  end

  Output('URL') do
    Description 'The URL of the website'
    Value FnJoin('', ['http://', FnGetAtt('LaunchConfig', 'DNSName')])
  end
end
