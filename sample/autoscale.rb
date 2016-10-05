
# We start things off by calling the CloudFormation function.
CloudFormation do
  # Declare the template format version
  AWSTemplateFormatVersion '2010-09-09'

  # As the DSL is really ruby, we get all of the different
  # ways to quote strings that come with ruby.
  Description %/
Create a multi-az, load balanced, Auto Scaled sample web site. The
Auto Scaling trigger is based on the CPU utilization of the web
servers. The AMI is chosen based on the region in which the stack is
run. This example creates a web service running across all
availability zones in a region. The instances are load balanced with a
simple health check. The web site is available on port 80, however,
the instances can be configured to listen on any port (8888 by
default).

**WARNING** This template creates one or more Amazon EC2
instances. You will be billed for the AWS resources used if you create
a stack from this template.
/

  # We can declare Parameters anywhere in the CloudFormation
  # block - these will get rolled up into the Parameters container
  # in the output.
  Parameter('InstanceType') do
    Description 'Type of EC2 instance to launch'
    Type 'String'
    Default 'm1.small'
  end

  Parameter('WebServerPort') do
    Description 'The TCP port for the Web Server'
    Type 'String'
    Default '8888'
  end

  Parameter('KeyName') do
    Description 'The EC2 Key Pair to allow SSH access to the instances'
    Type 'String'
  end

  # The same kind of thing for parameters works for mappings,
  # except that there is not a special object declared for mappings,
  # so we just have to build a hash of hashes which will be turned
  # directly into json.

  Mapping('AWSRegionArch2AMI',
          'us-east-1' => { '32' => 'ami-6411e20d', '64' => 'ami-7a11e213' },
          'us-west-1' => { '32' => 'ami-c9c7978c', '64' => 'ami-cfc7978a' },
          'eu-west-1' => { '32' => 'ami-37c2f643', '64' => 'ami-31c2f645' },
          'ap-southeast-1' => { '32' => 'ami-66f28c34', '64' => 'ami-60f28c32' },
          'ap-northeast-1' => { '32' => 'ami-9c03a89d', '64' => 'ami-a003a8a1' })

  # We can also write arbitrary ruby code

  # Here we build up a ruby hash
  architectures = {}
  ['t1.micro', 'm1.large', 'm1.xlarge', 'm2.xlarge', 'm2.2xlarge', 'm2.4xlarge', 'c1.xlarge', 'cc1.4xlarge'].each do |arch|
    # Iterate through the 64 bit machines to build a mapping for
    # 64 bit architecture
    architectures[arch] = { 'Arch' => '64' }
  end

  ['m1.small', 'c1.medium'].each do |arch|
    # iterate throught he 32 bit machine to build a mapping for
    # 32 bit architectures
    architectures[arch] = { 'Arch' => '32' }
  end

  Mapping('AWSInstanceType2Arch', architectures)
  # This will add a mapping entry equivalent to the following to the
  # template:
  #
  # 'AWSInstanceType2Arch' : {
  #   'm2.4xlarge' :  { 'Arch' : '64' },
  #   'c1.xlarge' :   { 'Arch' : '64' },
  #   'c1.medium' :   { 'Arch' : '32' },
  #   'm1.xlarge' :   { 'Arch' : '64' },
  #   'm1.large' :    { 'Arch' : '64' },
  #   't1.micro' :    { 'Arch' : '64' },
  #   'm1.small' :    { 'Arch' : '32' },
  #   'm2.2xlarge' :  { 'Arch' : '64' },
  #   'm2.xlarge' :   { 'Arch' : '64' },
  #   'cc1.4xlarge' : { 'Arch' : '64' }
  # }

  # Resources work similar to Parameters
  Resource('WebServerGroup') do
    Type 'AWS::AutoScaling::AutoScalingGroup'

    # To call aws template defined functions, call them like
    # functios (leaving out the double colons). For example
    # the following:
    Property('AvailabilityZones', FnGetAZs(''))
    # will generate JSON that includes
    #     { 'Fn::GetAZs : '' }
    # as the value of the AvailabilityZones property for the
    # 'WebServerGroup' reqource.

    # The same works for references
    Property('LaunchConfigurationName', Ref('LaunchConfig'))
    Property('MinSize', '1')
    Property('MaxSize', '3')

    # If you need to set a property value to a JSON array in
    # the template, you can just use a ruby array in the DSL.
    Property('LoadBalancerNames', [Ref('ElasticLoadBalancer')])
  end

  # You can use either strings or symbols for
  # Resource/Parameter/Mapping/Output names
  Resource(:LaunchConfig) do
    Type 'AWS::AutoScaling::LaunchConfiguration'

    Property('KeyName', Ref('KeyName'))
    Property('ImageId',
             FnFindInMap('AWSRegionArch2AMI', Ref('AWS::Region'),
                         FnFindInMap('AWSInstanceType2Arch', Ref('InstanceType'), 'Arch')))
    Property('UserData',       FnBase64(Ref('WebServerPort')))
    Property('SecurityGroups', [Ref('InstanceSecurityGroup')])
    Property('InstanceType',   Ref('InstanceType'))
  end

  Resource('WebServerScaleUpPolicy') do
    Type 'AWS::AutoScaling::ScalingPolicy'
    Property('AdjustmentType', 'ChangeInCapacity')
    Property('AutoScalingGroupName', Ref('WebServerGroup'))
    Property('Cooldown', '60')
    Property('ScalingAdjustment', '1')
  end

  Resource('WebServerScaleDownPolicy') do
    Type 'AWS::AutoScaling::ScalingPolicy'
    Property('AdjustmentType', 'ChangeInCapacity')
    Property('AutoScalingGroupName', Ref('WebServerGroup'))
    Property('Cooldown', '60')
    Property('ScalingAdjustment', '-1')
  end

  # You can use ruby language constructs to keep from repeating
  # yourself

  # declare an aray - we are going to use it to collect some
  # resources that we create
  alarms = []

  # When we declare a resource with 'Resource', we are
  # actually calling a method on CfnDsl::CloudFormationTemplate
  # that sets up the resource, and then returns it. We can use
  # the return value for other means.
  alarms.push Resource('CPUAlarmHigh') {
    Type 'AWS::CloudWatch::Alarm'
    Property('AlarmDescription', 'Scale-up if CPU > 90% for 10 minutes')
    Property('Threshold', '90')
    Property('AlarmActions', [Ref('WebServerScaleUpPolicy')])
    Property('ComparisonOperator', 'GreaterThanThreshold')
  }

  # Declare a second alarm resource and add it to our list
  alarms.push Resource('CPUAlarmLow') {
    Type 'AWS::CloudWatch::Alarm'
    Property('AlarmDescription', 'Scale-down if CPU < 70% for 10 minutes')
    Property('Threshold', '70')
    Property('AlarmActions', [Ref('WebServerScaleDownPolicy')])
    Property('ComparisonOperator', 'LessThanThreshold')
  }

  # Ok, the alarms that we previously declared actually share a bunch
  # of property declarations. Here we iterate through the alarms and
  # call declare on each one, passing in a code block. This works the
  # same as the declarations placed in the code blocks that went along
  # with the call to Resource that was used to create the resouce above.
  alarms.each do |alarm|
    alarm.declare do
      Property('MetricName', 'CPUUtilization')
      Property('Namespace', 'AWS/EC2')
      Property('Statistic', 'Average')
      Property('Period', '300')
      Property('EvaluationPeriods', '2')
      Property('Dimensions',
               [
                 {
                   'Name' => 'AutoScalingGroupName',
                   'Value' => Ref('WebServerGroup')
                 }
               ])
    end
  end

  Resource('ElasticLoadBalancer') do
    Type 'AWS::ElasticLoadBalancing::LoadBalancer'
    Property('AvailabilityZones', FnGetAZs(''))
    Property('Listeners',
             [
               {
                 'LoadBalancerPort' => '80',
                 'InstancePort' => Ref('WebServerPort'),
                 'Protocol' => 'HTTP'
               }
             ])
    Property('HealthCheck',
             'Target' => FnSub('HTTP:${WebServerPort}/'),
             'HealthyThreshold' => '3',
             'UnhealthyThreshold' => '5',
             'Interval' => '30',
             'Timeout' => '5')
  end

  Resource('InstanceSecurityGroup') do
    Type 'AWS::EC2::SecurityGroup'
    Property('GroupDescription', 'Enable SSH access and HTTP access on the inbound port')
    Property('SecurityGroupIngress',
             [
               {
                 'IpProtocol' => 'tcp',
                 'FromPort' => '22',
                 'ToPort' => '22',
                 'CidrIp' => '0.0.0.0/0'
               },
               {
                 'IpProtocol' => 'tcp',
                 'FromPort' => Ref('WebServerPort'),
                 'ToPort' => Ref('WebServerPort'),
                 'SourceSecurityGroupOwnerId' => FnGetAtt('ElasticLoadBalancer', 'SourceSecurityGroup.OwnerAlias'),
                 'SourceSecurityGroupName' => FnGetAtt('ElasticLoadBalancer', 'SourceSecurityGroup.GroupName')
               }
             ])
  end

  Output('URL') do
    Description 'The URL of the website'
    Value FnJoin('', ['http://', FnGetAtt('ElasticLoadBalancer', 'DNSName')])
  end
end
