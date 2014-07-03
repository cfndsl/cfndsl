require 'json';

require 'cfndsl/module'
require 'cfndsl/Errors'
require 'cfndsl/RefCheck'
require 'cfndsl/JSONable'
require 'cfndsl/Types'
require 'cfndsl/Properties'
require 'cfndsl/UpdatePolicy'
require 'cfndsl/Conditions'
require 'cfndsl/Mappings'
require 'cfndsl/Resources'
require 'cfndsl/Metadata'
require 'cfndsl/Parameters'
require 'cfndsl/Outputs'
require 'cfndsl/CloudFormationTemplate'

def CloudFormation(&block)
  x = CfnDsl::CloudFormationTemplate.new
  x.declare(&block)
  invalid_references = x.checkRefs()
  if( invalid_references ) then
    abort invalid_references.join("\n")
  elsif( CfnDsl::Errors.errors? ) then
    abort CfnDsl::Errors.errors.join("\n")
  else
    return x
  end
end

