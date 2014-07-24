CloudFormation {

  DESCRIPTION ||= "default description"
  MACHINES ||= 1

  Description DESCRIPTION

  (1..MACHINES).each do |i|
    name = "machine#{i}"
    Instance(name) {
      ImageId "ami-12345678"
      Type "t1.micro"
    }
  end
  
}
