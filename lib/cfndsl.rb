require 'json';

require 'cfndsl/module'
require 'cfndsl/Errors'
require 'cfndsl/RefCheck'
require 'cfndsl/JSONable'
require 'cfndsl/Types'
require 'cfndsl/Properties'
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
    $stderr.puts invalid_references.join("\n");
    exit(-1)
  elsif( CfnDsl::Errors.errors? ) then
    CfnDsl::Errors.report
  else
    x.generateOutput
  end
end


