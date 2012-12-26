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
    BlockDeviceMapping() {
      DeviceName "/dev/sda"
      VirtualName "stuff"
      Ebs() {
        SnapshotId "asdasdfasdf"
        VolumeSize "200G"
      }
    }
  }

}
