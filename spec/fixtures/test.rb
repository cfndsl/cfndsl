# frozen_string_literal: true

CloudFormation do
  Description external_parameters[:test]

  Parameter('One') do
    String
    Default 'Test'
    MaxLength 15
  end

  Parameter('Two') do
    String
    Default 'Test'
    MaxLength 15
  end

  Parameter('Three') do
    String
    Default external_parameters[:three]
  end

  # Condition Function examples
  Condition('OneIsTest', FnEquals(Ref('One'), 'Test'))
  Condition('OneIsNotTest', FnNot(FnEquals(Ref('One'), 'Test')))
  Condition('OneIsTestAndTwoIsTest',
            FnAnd(
              [
                FnEquals(Ref('One'), 'Test'),
                FnNot(FnEquals(Ref('Two'), 'Test'))
              ]
            ))

  Condition('OneIsTestOrTwoIsTest',
            FnOr(
              [
                FnEquals(Ref('One'), 'Test'),
                FnEquals(Ref('Two'), 'Test')
              ]
            ))

  Output(:One, FnBase64(Ref('One')))

  Resource('MyInstance') do
    Condition 'OneIsNotTest'
    Type 'AWS::EC2::Instance'
    Property('ImageId', 'ami-14341342')
  end

  LaunchConfiguration('Second') do
    Condition 'OneIsNotTest'
    BlockDeviceMapping do
      DeviceName '/dev/sda'
      VirtualName 'stuff'
      Ebs do
        SnapshotId external_parameters[:test]
        VolumeSize Ref('MyInstance')
      end
    end
  end

  Parameter('ElbSubnets') do
    Type 'CommaDelimitedList'
    Default 'subnet-12345, subnet-54321'
  end

  Resource('ElasticLoadBalancer') do
    Type 'AWS::ElasticLoadBalancing::LoadBalancer'
    Property('Subnets', [FnSelect('0', Ref('ElbSubnets')), FnSelect('1', Ref('ElbSubnets'))])
  end

  AutoScalingGroup('ASG') do
    UpdatePolicy('AutoScalingRollingUpdate',
                 'MinInstancesInService' => '1',
                 'MaxBatchSize' => '1',
                 'PauseTime' => 'PT15M')
    AvailabilityZones FnGetAZs('')
    LaunchConfigurationName Ref('LaunchConfig')
    MinSize 1
    MaxSize FnIf('OneIsTest', 1, 3)
    LoadBalancerNames Ref('ElasticLoadBalancer')
  end

  LaunchConfiguration('LaunchConfig')

  # UndefinedResource('asddfasdf')
end
