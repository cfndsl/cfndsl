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

  EC2_SecurityGroup("Second") {
    GroupDescription "Xyz"
    SecurityGroupIngress {
      SourceSecurityGroupName "Test"
      IpProtocol "tcp"
      FromPort 80
      ToPort 81
      CidrIp "10.5.0.0/16"
    }
  }

}
