CloudFormation {
  Description "Test"

  Parameter("One") {
    String
    Default "Test"
    MaxLength 15
  }

  Parameter('Two') {
    String
    Default 'Test'
    MaxLength 15
  }

  # Condition Function examples
  Condition('OneIsTest', FnEquals(Ref('One'), 'Test'))
  Condition('OneIsNotTest', FnNot(FnEquals(Ref('One'), 'Test')))
  Condition('OneIsTestAndTwoIsTest', FnAnd([
    FnEquals(Ref('One'), 'Test'),
    FnNot(FnEquals(Ref('Two'), 'Test')),
  ]))

  Condition('OneIsTestOrTwoIsTest', FnOr([
    FnEquals(Ref('One'), 'Test'),
    FnEquals(Ref('Two'), 'Test'),
  ]))

  Output(:One, FnBase64(Ref("One")))

  Resource("MyInstance") {
    Condition 'OneIsNotTest'
    Type "AWS::EC2::Instance"
    Property("ImageId", "ami-14341342")
  }

  LaunchConfiguration("Second") {
    Condition 'OneIsNotTest'
    BlockDeviceMapping {
      DeviceName "/dev/sda"
      VirtualName "stuff"
      Ebs {
        SnapshotId "asdasdfasdf"
        VolumeSize Ref("MyInstance")
      }
    }
  }

  AutoScalingGroup("ASG") {
    AvailabilityZones FnGetAZs("")
    LaunchConfigurationName Ref("LaunchConfig")
    MinSize 1
    MaxSize FnIf('OneIsTest', 1, 3)
    LoadBalancer Ref("ElasticLoadBalancer")
  }

  LaunchConfiguration("LaunchConfig")
  LoadBalancer("ElasticLoadBalancer")

  UndefinedResource("asddfasdf")
}
