Gem::Specification.new do |s|
  s.name        = 'cfndsl'
  s.version     = '0.0.14'
  s.date        = '2013-05-16'
  s.summary     = "AWS Cloudformation DSL"
  s.description = "DSL for creating AWS Cloudformation templates"
  s.authors     = ["Chris Howe"]
  s.email       = 'chris@howeville.com'
  s.files       = [ "lib/cfndsl.rb",
                    "lib/cfndsl/aws_types.yaml",
                    "lib/cfndsl/JSONable.rb",
                    "lib/cfndsl/module.rb",
                    "lib/cfndsl/RefCheck.rb",
                    "lib/cfndsl/Types.rb",
                    'lib/cfndsl/Properties.rb',
                    'lib/cfndsl/Mappings.rb',
                    'lib/cfndsl/Resources.rb',
                    'lib/cfndsl/Metadata.rb',
                    'lib/cfndsl/Parameters.rb',
                    'lib/cfndsl/Outputs.rb',
                    'lib/cfndsl/Errors.rb',
                    'lib/cfndsl/Plurals.rb',
                    'lib/cfndsl/names.rb',
                   'lib/cfndsl/CloudFormationTemplate.rb'  
                  ]
  s.executables = ["cfndsl"]
  s.homepage    = 'https://github.com/howech/cfndsl'
end

