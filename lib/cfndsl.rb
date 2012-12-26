require 'json';

require 'cfndsl/module'
require 'cfndsl/RefCheck'
require 'cfndsl/JSONable'
require 'cfndsl/Types'
require 'cfndsl/Properties'
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
    puts invalid_references.join("\n");
    exit(-1)
  else
    x.generateOutput
  end
end


