
CloudFormation {
  AWSTemplateFormatVersion "2010-09-09"

  Description "Circular Reference"

  Parameter("InstanceType") {
      Description "Type of EC2 instance to launch"
      Type "String"
      Default "m1.small"
  }

  Resource("WebServerGroup") {
    Type "AWS::AutoScaling::AutoScalingGroup"
    Property("AvailabilityZones", FnGetAZs("") )
    Property("LaunchConfigurationName", Ref( "LaunchConfig") )
    Property("MinSize", "1")
    Property("MaxSize", "3")
  }


  Resource( "LaunchConfig" ) {
    Type "AWS::AutoScaling::LaunchConfiguration"
    DependsOn ["WebServerGroup"]
    Property("InstanceType",   Ref("InstanceType") )
  }


  Output( "URL" ) {
    Description "The URL of the website"
    Value FnJoin( "", [ "http://", FnGetAtt( "LaunchConfig", "DNSName" ) ] )
  }
}
