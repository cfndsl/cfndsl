Heat {
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

  Output(:One, FnBase64(Ref("One")))

  Server("MyInstance") {
    flavor "asdfa"
    image "asdad"    
  }

}
