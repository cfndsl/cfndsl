cfndsl
======

[![Build Status](https://travis-ci.org/stevenjack/cfndsl.png?branch=master)](https://travis-ci.org/stevenjack/cfndsl)
[![Gem Version](https://badge.fury.io/rb/cfndsl.png)](http://badge.fury.io/rb/cfndsl)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/stevenjack/cfndsl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

[AWS Cloudformation](http://docs.amazonwebservices.com/AWSCloudFormation/latest/UserGuide/GettingStarted.html) templates are an incredibly powerful way to build
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

  EC2_Instance(:MyInstance) {
    ImageId "ami-12345678"
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
            "ImageId" : "ami-12345678"
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

*Aside: that is correct - a significant amount of the development for
this gem was done on a [Raspberry Pi](http://www.raspberrypi.org).*

## Samples

There is a more detailed example in the samples directory. The file
"autoscale.template" is one of the standard Amazon sample templates.
"autoscale.rb" generates an equivalent template file.

## Command Line Options

The cfndsl command line program now accepts some command line options.

```
Usage: cfndsl [options] FILE
    -o, --output FILE                Write output to file
    -y, --yaml FILE                  Import yaml file as local variables
    -r, --ruby FILE                  Evaluate ruby file before template
    -j, --json FILE                  Import json file as local variables
    -D, --define "VARIABLE=VALUE"    Directly set local VARIABLE as VALUE
    -v, --verbose                    Turn on verbose ouptut
    -h, --help                       Display this screen
```

By default, cfndsl will attempt to evaluate FILE as cfndsl template and print
the resulting cloudformation json template to stdout. With the -o option, you
can instead have it write the resulting json template to a given file. The -v
option prints out additional information (to stderr) about what is happening
in the model generation process.

The -y, -j, -r and -D options can be used to control some things about the
environment that the template code gets evaluate in. For instance, the -D
option allows you to set a variable at the command line that can then be
referred to within the template itself.

This is best illustrated with a example. Consider the following cfndsl
template

```ruby
# cfndsl template t1.rb
CloudFormation {

  DESCRIPTION ||= "default description"
  MACHINES ||= 3

  Description DESCRIPTION

  (1..MACHINES).each do |i|
    name = "machine#{i}"
    EC2_Instance(name) {
      ImageId "ami-12345678"
      Type "t1.micro"
    }
  end

}
```

Note the two variables "DESCRIPTION" and "MACHINES". The template
sets these to some reasonable default values, and if you run cfndsl
on it without changing them in any way you get the following cloudformation
template:

```json
{
  "Resources": {
    "machine1": {
      "Type": "AWS::EC2::Instance",
      "Properties": {
        "ImageId": "ami-12345678"
      }
    }
  },
  "Description": "default description",
  "AWSTemplateFormatVersion": "2010-09-09"
}
```

However if you run the command

```bash
$ cfndsl t1.rb -D 'DESCRIPTION="3 machine cluster"' -D 'MACHINES=3'
```

you get the following generated template.

```json
{
  "Resources": {
    "machine3": {
      "Type": "AWS::EC2::Instance",
      "Properties": {
        "ImageId": "ami-12345678"
      }
    },
    "machine2": {
      "Type": "AWS::EC2::Instance",
      "Properties": {
        "ImageId": "ami-12345678"
      }
    },
    "machine1": {
      "Type": "AWS::EC2::Instance",
      "Properties": {
        "ImageId": "ami-12345678"
      }
    }
  },
  "Description": "3 machine cluster",
  "AWSTemplateFormatVersion": "2010-09-09"
}
```

The -y and -j options allow you to group several variable definitions
into a single file (formated as either yaml or ruby respectively). If
you had a file called 't1.yaml' that contained the following,

```yaml
# t1.yaml
DESCRIPTION: 5 machine cluster
MACHINES: 5
```

the command

```bash
$ cfndsl t1.rb -y t1.yaml
```

would generate a template with 5 instances declared.

Finally, the -r option gives you the opportunity to execute some
arbitrary ruby code in the evaluation context before the cloudformation
template is evaluated.

### Rake task
Simply add the following to your `Rakefile`:

```ruby
require 'cfndsl/rake_task'

CfnDsl::RakeTask.new do |t|
  t.cfndsl_opts = {
    verbose: true,
    files: [{
      filename: 'templates/application.rb',
      output: 'application.json'
    }],
    extras: [
      [ :yaml, 'templates/default_params.yml' ]
    ]
  }
end
```

And then use rake to generate the cloudformation:

```bash
$ bin/rake generate
```
