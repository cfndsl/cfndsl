CloudFormation {
  Description "Test"
  
  Parameter("One") {
    String
    Default "Test"
	MaxLength 15
  }
 
  Output(:One,FnBase64( Ref("One")))

  Resource("MyInstance") {
	Type "AWS::EC2::Instance"
	Property("ImageId","ami-14341342")
  }

  LaunchConfiguration("Second") {
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
    UpdatePolicy("AutoScalingRollingUpdate", {
                 "MinInstancesInService" => "1",
                 "MaxBatchSize"          => "1",
                 "PauseTime"             => "PT15M"
                 })
    AvailabilityZones FnGetAZs("")
    LaunchConfigurationName Ref("LaunchConfig")
    MinSize 1
    MaxSize 3
    LoadBalancer Ref("ElasticLoadBalancer")
  }

  LaunchConfiguration("LaunchConfig")
  LoadBalancer("ElasticLoadBalancer")


  UndefinedResource("asddfasdf")
}
