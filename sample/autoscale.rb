require '../lib/cfndsl'

CloudFormation {
  AWSTemplateFormatVersion "2010-09-09"

  Description "Create a multi-az, load balanced, Auto Scaled sample web site. The Auto Scaling trigger is based on the CPU utilization of the web servers. The AMI is chosen based on the region in which the stack is run. This example creates a web service running across all availability zones in a region. The instances are load balanced with a simple health check. The web site is available on port 80, however, the instances can be configured to listen on any port (8888 by default). **WARNING** This template creates one or more Amazon EC2 instances. You will be billed for the AWS resources used if you create a stack from this template."

  Parameter("InstanceType") {
      Description "Type of EC2 instance to launch"
      Type "String"
      Default "m1.small"
  }

  Parameter( "WebServerPort") {
    Description "The TCP port for the Web Server"
    Type "String"
    Default "8888"
  }
  Parameter("KeyName") {
    Description "The EC2 Key Pair to allow SSH access to the instances"
    Type "String"
  }

  Mapping("AWSInstanceType2Arch", {
            "t1.micro"    => { "Arch" => "64" },
            "m1.small"    => { "Arch" => "32" },
            "m1.large"    => { "Arch" => "64" },
            "m1.xlarge"   => { "Arch" => "64" },
            "m2.xlarge"   => { "Arch" => "64" },
            "m2.2xlarge"  => { "Arch" => "64" },
            "m2.4xlarge"  => { "Arch" => "64" },
            "c1.medium"   => { "Arch" => "32" },
            "c1.xlarge"   => { "Arch" => "64" },
            "cc1.4xlarge" => { "Arch" => "64" }
          })

  Mapping("AWSRegionArch2AMI", {
            "us-east-1" => { "32" => "ami-6411e20d", "64" => "ami-7a11e213" },
            "us-west-1" => { "32" => "ami-c9c7978c", "64" => "ami-cfc7978a" },
            "eu-west-1" => { "32" => "ami-37c2f643", "64" => "ami-31c2f645" },
            "ap-southeast-1" => { "32" => "ami-66f28c34", "64" => "ami-60f28c32" },
            "ap-northeast-1" => { "32" => "ami-9c03a89d", "64" => "ami-a003a8a1" }
    })

  Resource("WebServerGroup") {
    Type "AWS::AutoScaling::AutoScalingGroup"
    Property("AvailabilityZones", FnGetAZs("") )
    Property("LaunchConfigurationName", Ref( "LaunchConfig") )
    Property("MinSize", "1")
    Property("MaxSize", "3")
    Property("LoadBalancerNames", [ Ref( "ElasticLoadBalancer") ] )
  }


  Resource( "LaunchConfig" ) {
    Type "AWS::AutoScaling::LaunchConfiguration"

    Property("KeyName", Ref("KeyName") )
    Property( "ImageId", 
              FnFindInMap( "AWSRegionArch2AMI", Ref("AWS::Region"),
                           FnFindInMap( "AWSInstanceType2Arch", Ref("InstanceType"),"Arch")))
    Property("UserData",       FnBase64( Ref("WebServerPort")))
    Property("SecurityGroups", [ Ref("InstanceSecurityGroup")])
    Property("InstanceType",   Ref("InstanceType") )
  }


  Resource( "WebServerScaleUpPolicy" ) {
    Type "AWS::AutoScaling::ScalingPolicy"
    Property("AdjustmentType", "ChangeInCapacity")
    Property("AutoScalingGroupName", Ref( "WebServerGroup") )
    Property("Cooldown", "60")
    Property("ScalingAdjustment", "1")
  }
   
  Resource("WebServerScaleDownPolicy") {
    Type "AWS::AutoScaling::ScalingPolicy"
    Property("AdjustmentType", "ChangeInCapacity")
    Property("AutoScalingGroupName", Ref( "WebServerGroup" ))
    Property("Cooldown", "60")
    Property("ScalingAdjustment", "-1")
  }
  
  Resource("CPUAlarmHigh") {
    Type "AWS::CloudWatch::Alarm"
    Property("AlarmDescription", "Scale-up if CPU > 90% for 10 minutes")
    Property("MetricName", "CPUUtilization")
    Property("Namespace", "AWS/EC2")
    Property("Statistic", "Average")
    Property("Period", "300")
    Property("EvaluationPeriods", "2")
    Property("Threshold", "90")
    Property("AlarmActions", [ Ref("WebServerScaleUpPolicy" ) ])
    Property("Dimensions", [
          {
            "Name"=> "AutoScalingGroupName",
            "Value"=> Ref("WebServerGroup" )
          }
        ])
    Property("ComparisonOperator", "GreaterThanThreshold")
  }

  Resource("CPUAlarmLow") {
    Type "AWS::CloudWatch::Alarm"
    Property("AlarmDescription", "Scale-down if CPU < 70% for 10 minutes")
    Property("MetricName", "CPUUtilization")
    Property("Namespace", "AWS/EC2")
    Property("Statistic", "Average")
    Property("Period", "300")
    Property("EvaluationPeriods", "2")
    Property("Threshold", "70")
    Property("AlarmActions", [ Ref("WebServerScaleDownPolicy" ) ])
    Property("Dimensions", [
                            {
                              "Name" => "AutoScalingGroupName",
                              "Value" => Ref("WebServerGroup" )
                            }
                           ])
    Property("ComparisonOperator", "LessThanThreshold")
  }

  Resource( "ElasticLoadBalancer" ) {
    Type "AWS::ElasticLoadBalancing::LoadBalancer"
    Property( "AvailabilityZones", FnGetAZs(""))
    Property( "Listeners" , [ {
                                "LoadBalancerPort" => "80",
                                "InstancePort" => Ref( "WebServerPort" ),
                                "Protocol" => "HTTP"
                              } ] )
    Property( "HealthCheck" , {
                "Target" => FnJoin( "", ["HTTP:", Ref( "WebServerPort" ), "/"]),
                "HealthyThreshold" => "3",
                "UnhealthyThreshold" => "5",
                "Interval" => "30",
                "Timeout" => "5"
              })
  }
  
  Resource("InstanceSecurityGroup" ) {
    Type "AWS::EC2::SecurityGroup"
    Property("GroupDescription" , "Enable SSH access and HTTP access on the inbound port")
    Property("SecurityGroupIngress", [ {
          "IpProtocol" => "tcp",
          "FromPort" => "22",
          "ToPort" => "22",
          "CidrIp" => "0.0.0.0/0"
        },
        {
          "IpProtocol" => "tcp",
          "FromPort" => Ref( "WebServerPort" ),
          "ToPort" => Ref( "WebServerPort" ),
          "SourceSecurityGroupOwnerId" => FnGetAtt("ElasticLoadBalancer", "SourceSecurityGroup.OwnerAlias"),
          "SourceSecurityGroupName" => FnGetAtt("ElasticLoadBalancer", "SourceSecurityGroup.GroupName")
        } ])
  }
  Output( "URL" ) {
    Description "The URL of the website"
    Value FnJoin( "", [ "http://", FnGetAtt( "ElasticLoadBalancer", "DNSName" ) ] )
  }
}
