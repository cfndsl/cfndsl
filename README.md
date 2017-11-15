cfndsl
======

[![Build Status](https://travis-ci.org/cfndsl/cfndsl.png?branch=master)](https://travis-ci.org/cfndsl/cfndsl)
[![Gem Version](https://badge.fury.io/rb/cfndsl.png)](http://badge.fury.io/rb/cfndsl)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/cfndsl/cfndsl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

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

ruby version > 2.1.0 is required to run cfndsl

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

## Syntax

`cfndsl` comes with a number of helper methods defined on _each_ resource and/or the stack as a whole.

### Template Metadata

Metadata is a special template section described [here](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/metadata-section-structure.html). The argument supplied must be JSON-able. Some CloudFormation features reference special keys if included in the `Metadata`, check the AWS documentation for specifics.

```ruby
CloudFormation do
  Metadata(foo: 'bar')

  EC2_Instance(:myInstance) do
    ImageId 'ami-12345678'
    Type 't1.micro'
  end
end
```

### Template Parameters

At a bare minumum, parameters need a name, and default to having Type `String`. Specify the parameter in the singular, not plural:

```ruby
CloudFormation do
  Parameter 'foo'
end
```

```json
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Parameters": {
    "foo": {
      "Type": "String"
    }
  }
}
```

However, they can accept all of the following additional keys per the [documentation](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html):

```ruby
Parameter('foo') do
  Description           'This is a sample parameter definition'
  Type                  'String'
  Default               'foo'
  NoEcho                true
  AllowedValues         %w(foo bar)
  AllowedPattern        '/pattern/'
  MaxLength             5
  MinLength             3
  MaxValue              10
  MinValue              2
  ConstraintDescription 'The error message printed when a parameter outside the constraints is given'
end
```

Parameters can be referenced later in your template:

```ruby
EC2_Instance(:myInstance) do
  InstanceType 'm3.xlarge'
  UserData Ref('foo')
end
```

### Template Mappings

[Mappings](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/mappings-section-structure.html) are a hash-based lookup for your template. They can be specified in the singular or plural.

```ruby
CloudFormation do
  Mapping('foo', letters: { a: 'a', b: 'b' }, numbers: { 1: 1, 2: 2 })
end
```

```json
{
  "AWSTemplateFormatVersion": "2010-09-09",
    "Mappings": {
      "foo": {
	"letters": {
	  "a": "a",
	  "b": "b"
	},
	"numbers": {
	  "one": 1,
	  "two": 2
	}
      }
    }
  }
}
```

You can then reference them later in your template using the `FnFindInMap` method:

```ruby
EC2_Instance(:myInstance) do
  InstanceType 'm3.xlarge'
  UserData FnFindInMap('foo', :numbers, :one)
end
```

### Template Outputs

Outputs are declared one at a time and must be given a name and a value at a minimum, description is optional. Values are most typically obtained from other resources using `Ref` or `FnGetAtt`:

```ruby
CloudFormation do
  EC2_Instance(:myInstance) do
    ImageId 'ami-12345678'
    Type 't1.micro'
  end

  Output(:myInstanceId) do
    Description 'My instance Id'
    Value Ref(:myInstance)
  end
end
```

```json
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "myInstance": {
      "Properties": {
	"ImageId": "ami-12345678"
      },
      "Type": "AWS::EC2::Instance"
    }
  },
  "Outputs": {
    "myInstanceId": {
      "Description": "My instance Id",
      "Value": {
	"Ref": "myInstance"
      }
    }
  }
}
```

### Template Conditions

Conditions must be created with statements in three [sections](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/conditions-section-structure.html): a variable entry as a `Parameter`, a template-level `Condition` that holds the logic based upon the value of that `Parameter`, and a resource-level `Condition` that references the template-level one by logical id.

```ruby
CloudFormation do
  Parameter(:environment) do
    Default 'development'
    AllowedValues %w(production development)
  end

  Condition(:createResource, FnEquals(Ref(:environment), 'production'))

  EC2_Instance(:myInstance) do
    Condition :createResource
    ImageId 'ami-12345678'
    Type 't1.micro'
  end
end
```

```json
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Parameters": {
    "environment": {
      "Type": "String",
      "Default": "development",
      "AllowedValues": [
	"production",
	"development"
      ]
    }
  },
  "Conditions": {
    "createResource": {
      "Fn::Equals": [
	{
	  "Ref": "environment"
	},
	"production"
      ]
    }
  },
  "Resources": {
    "myInstance": {
      "Condition": "createResource",
      "Properties": {
	"ImageId": "ami-12345678"
      },
      "Type": "AWS::EC2::Instance"
    }
  }
}
```

### Template Resources

Cfndsl creates accessor methods for all of the resources listed [here](https://github.com/cfndsl/cfndsl/blob/master/lib/cfndsl/aws/types.yaml) and [here](https://github.com/cfndsl/cfndsl/blob/master/lib/cfndsl/os/types.yaml). If a resource is missing, or if you prefer to explicitly enter a resource in a template, you can do so. Keep in mind that since you are using the generic `Resource` class, you will also need to explicitly set the `Type` and that you no longer have access to the helper methods defined on that particular class, so you will have to use the `Property` method to set them.

```ruby
CloudFormation do
  Resource(:myInstance) do
    Type 'AWS::EC2::Instance'
    Property('ImageId', 'ami-12345678')
    Property('Type', 't1.micro')
  end

  # Will generate the same json as this
  #
  # EC2_Instance(:myInstance) do
  #   ImageId 'ami-12345678'
  #   Type 't1.micro'
  # end
end
```

```json
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "myInstance": {
      "Type": "AWS::ApiGateway::Resource",
      "Properties": {
	"ImageId": "ami-12345678",
	"Type": "t1.micro"
      }
    }
  }
}
```

### Resource Types

When using the generic `Resource` method, rather than the dsl methods, specify the type of resource using `Type` and the properties using `Property`. See [Template Resources](#template-resources) for an example.

### Resource Conditions

Resource conditions are specified singularly, referencing a template-level condition by logical id. See [Template Conditions](#template-conditions) for an example.

### Resource DependsOn

Resources can depend upon other resources explicitly using `DependsOn`. It accepts one or more logical ids.

```ruby
CloudFormation do
  EC2_Instance(:database) do
    ImageId 'ami-12345678'
    Type 't1.micro'
  end

  EC2_Instance(:webserver) do
    DependsOn :database
    ImageId 'ami-12345678'
    Type 't1.micro'
  end
end
```

```json
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "database": {
      "Properties": {
	"ImageId": "ami-12345678"
      },
      "Type": "AWS::EC2::Instance"
    },
    "webserver": {
      "Properties": {
	"ImageId": "ami-12345678"
      },
      "Type": "AWS::EC2::Instance",
      "DependsOn": "database"
    }
  }
}
```

### Resource DeletionPolicy

Resources can have [deletion policies](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html) associated with them. Specify them one per resource as an attribute:

```ruby
CloudFormation do
  EC2_Instance(:myInstance) do
    DeletionPolicy 'Retain'
    ImageId 'ami-12345678'
    Type 't1.micro'
  end
end
```

### Resource Metadata

You can attach arbitrary [metadata](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-metadata.html) as an attribute. Arguments provided must be able to be JSON-ified:

```ruby
CloudFormation do
  EC2_Instance(:myInstance) do
    Metadata(foo: 'bar')
    ImageId 'ami-12345678'
    Type 't1.micro'
  end
end
```

### Resource CreationPolicy/UpdatePolicy

These attributes are only usable on particular [resources](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-creationpolicy.html). The name of the attribute is not arbitrary, it must match the policy name you are trying to attach. Different policies have different parameters.

```ruby
CloudFormation do
  EC2_Instance(:myInstance) do
    ImageId 'ami-12345678'
    Type 't1.micro'
    CreationPolicy(:ResourceSignal, { Count: 1, Timeout: 'PT1M' })
  end
end
```

## Samples

There is a more detailed example in the samples directory. The file
"autoscale.template" is one of the standard Amazon sample templates.
"autoscale.rb" generates an equivalent template file.

There's also a larger set of examples available at [cfndsl_examples](https://github.com/neillturner/cfndsl_examples) thanks to @neillturner.

## Command Line Options

The cfndsl command line program now accepts some command line options.

```
Usage: cfndsl [options] FILE
    -o, --output FILE                Write output to file
    -y, --yaml FILE                  Import yaml file as local variables
    -r, --ruby FILE                  Evaluate ruby file before template
    -j, --json FILE                  Import json file as local variables
    -p, --pretty                     Pretty-format output JSON
    -f, --format FORMAT              Specify the output format (JSON default)
    -D, --define "VARIABLE=VALUE"    Directly set local VARIABLE as VALUE
    -v, --verbose                    Turn on verbose ouptut
    -b, --disable-binding            Disable binding configuration
    -m, --disable-deep-merge         Disable deep merging of yaml
    -s, --specification-file FILE    Location of Cloudformation Resource Specification file
    -u, --update-specification       Update the Cloudformation Resource Specification file
    -g RESOURCE_TYPE,RESOURCE_LOGICAL_NAME,
        --generate                   Add resource type and logical name
    -l, --list                       List supported resources
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
# cfndsl template sample/t1.rb
CloudFormation do

  description = external_parameters.fetch(:description, 'default description')
  machines = external_parameters.fetch(:machines, 1).to_i

  Description description

  (1..machines).each do |i|
    name = "machine#{i}"
    EC2_Instance(name) do
      ImageId 'ami-12345678'
      Type 't1.micro'
    end
  end

end
```

Note the two variables `description` and `machines`. The template
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
$ cfndsl sample/t1.rb -D 'description=3 machine cluster' -D 'machines=3'
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
into a single file (formated as either yaml or json respectively). If
you had a file called 't1.yaml' that contained the following,

```yaml
# sample/t1.yaml
description: 5 machine cluster
machines: 5
```

the command

```bash
$ cfndsl sample/t1.rb -y sample/t1.yaml
```

would generate a template with 5 instances declared.

Specifying multiple -y options will default deep_merge all the yaml in the order specified.
You can disable this with -m.

Finally, the -r option gives you the opportunity to execute some
arbitrary ruby code in the evaluation context before the cloudformation
template is evaluated (this is not available if `--disable-binding` is used).

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

### Generating CloudFormation resources from cfndsl
By supplying the -g paramater you are now able to generate cloudformation resources for supported objects, for a list of supported resources run cfndsl -l

Example
```bash
cfndsl -g AWS::EC2::EIP,EIP
```
```ruby
require 'cfndsl'
CloudFormation do
  Description 'auto generated cloudformation cfndsl template'

  EC2_EIP('EIP') do
        Domain String # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-eip.html#cfn-ec2-eip-domain
        InstanceId String # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-eip.html#cfn-ec2-eip-instanceid
  end
end
```
Many thanks to the base code from cfnlego to make this possible!
