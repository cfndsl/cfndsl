Gem::Specification.new do |s|
  s.name        = 'cfndsl'
  s.version     = '0.1.11'
  s.summary     = "AWS Cloudformation DSL"
  s.description = "DSL for creating AWS Cloudformation templates"
  s.authors     = ['Steven Jack', 'Chris Howe']
  s.email       = ['stevenmajack@gmail.com', 'chris@howeville.com']
  s.files       = [ "lib/cfndsl.rb",
		    "lib/cfndsl/aws_types.yaml",
		    "lib/cfndsl/os_types.yaml",
		    "lib/cfndsl/JSONable.rb",
		    "lib/cfndsl/module.rb",
		    "lib/cfndsl/RefCheck.rb",
		    "lib/cfndsl/Types.rb",
		    'lib/cfndsl/Properties.rb',
		    'lib/cfndsl/Conditions.rb',
		    'lib/cfndsl/Mappings.rb',
		    'lib/cfndsl/Resources.rb',
		    'lib/cfndsl/Metadata.rb',
		    'lib/cfndsl/Parameters.rb',
		    'lib/cfndsl/Outputs.rb',
		    'lib/cfndsl/Errors.rb',
		    'lib/cfndsl/Plurals.rb',
		    'lib/cfndsl/names.rb',
		    'lib/cfndsl/CloudFormationTemplate.rb',
        'lib/cfndsl/CreationPolicy.rb',
		    'lib/cfndsl/UpdatePolicy.rb'
		  ]
  s.executables = ['cfndsl']
  s.homepage    = 'https://github.com/stevenjack/cfndsl'
  s.license     = 'MIT'

  s.add_development_dependency 'bundler'
end
