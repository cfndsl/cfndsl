Gem::Specification.new do |s|
  s.name        = 'cfndsl'
  s.version     = '0.0.4'
  s.date        = '2012-12-16'
  s.summary     = "AWS Cloudformation DSL"
  s.description = "DSL for creating AWS Cloudformation templates"
  s.authors     = ["Chris Howe"]
  s.email       = 'chris@howeville.com'
  s.files       = ["lib/cfndsl.rb","lib/cfndsl/aws_types.yaml","lib/cfndsl/JSONable.rb","lib/cfndsl/module.rb","lib/cfndsl/RefCheck.rb","lib/cfndsl/Types.rb"]
  s.executables = ["cfndsl"]
  s.homepage    = 'https://github.com/howech/cfndsl'
end

