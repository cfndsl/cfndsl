
cfndsl
======


AWS Cloudformation templates are an incredibly powerful way to build
sets of resources in Amazon's AWS environment. Unfortunately, because
they are specified in JSON, they are also difficult to write and
maintain:

* JSON does not allow comments

* All structures are JSON, so it is sometimes easy for a person
  reading a template to get lost.
  
* References and internal functions have a particularly unpleasant syntax.


The cnfdsl gem provides a simple DSL that allows you to write equivalent
templates in a more friendly language and generate the correct json
templates by running ruby.

## Getting Started

    sudo gem install cfndsl
	
Now write a template in the dsl
   
```ruby

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
  
}
```

Then run cfndsl on the file

```
chris@raspberrypi:~/git/cfndsl$ cfndsl test.rb | json_pp
{
   "Parameters" : {
      "One" : {
         "Type" : "String",
         "Default" : "Test",
         "MaxLength" : 15
      }
   },
   "Resources" : {
      "MyInstance" : {
         "Type" : "AWS::EC2::Instance",
         "Properties" : {
            "ImageId" : "ami-14341342"
         }
      }
   },
   "AWSTemplateFormatVersion" : "2010-09-09",
   "Outputs" : {
      "One" : {
         "Value" : {
            "Fn::Base64" : {
               "Ref" : "One"
            }
         }
      }
   },
   "Description" : "Test"
}
```

## Samples

There is a more detailed example in the samples directory. The file
"autoscale.template" is one of the standard Amazon sample templates. 
"autoscale.rb" generates an equivalent template file.


