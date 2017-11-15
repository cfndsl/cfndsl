module CfnDsl
  # Module for handling inconsistencies in the published resource specification from AWS
  module Patches
    # Missing/malformed resources from the resource specification
    # rubocop:disable Metrics/MethodLength
    def self.resources
      {
        'AWS::Serverless::Function' => {
          'Properties' => {
            'Handler'     => { 'PrimitiveType' => 'String' },
            'Runtime'     => { 'PrimitiveType' => 'String' },
            'CodeUri'     => { 'PrimitiveType' => 'String' },
            'Description' => { 'PrimitiveType' => 'String' },
            'MemorySize'  => { 'PrimitiveType' => 'Integer' },
            'Timeout'     => { 'PrimitiveType' => 'Integer' },
            'Environment' => { 'PrimitiveType' => 'Json' },
            'Events'      => { 'PrimitiveType' => 'Json' },
            'Policies'    => { 'Type' => 'List', 'ItemType' => 'Policy' }
          }
        },
        'AWS::Serverless::Api' => {
          'Properties' => {
            'StageName'           => { 'PrimitiveType' => 'String' },
            'DefinitionUri'       => { 'PrimitiveType' => 'String' },
            'CacheClusterEnabled' => { 'PrimitiveType' => 'Boolean' },
            'CacheClusterSize'    => { 'PrimitiveType' => 'String' },
            'Variables'           => { 'PrimitiveType' => 'Json' }
          }
        },
        'AWS::Serverless::SimpleTable' => {
          'Properties' => {
            'PrimaryKey' => { 'Type' => 'PrimaryKey' },
            'ProvisionedThroughput' => { 'Type' => 'ProvisionedThroughput' }
          }
        },
        'AWS::SSM::Parameter' => {
          'Properties' => {
            'Name'        => { 'PrimitiveType' => 'String' },
            'Description' => { 'PrimitiveType' => 'String' },
            'Type'        => { 'PrimitiveType' => 'String' },
            'Value'       => { 'PrimitiveType' => 'String' }
          }
        }
      }
    end

    # Missing/malformed types from the resource specification
    def self.types
      {
        'AWS::Serverless::SimpleTable.PrimaryKey' => {
          'Properties' => {
            'Name' => { 'PrimitiveType' => 'String' },
            'Type' => { 'PrimitiveType' => 'String' }
          }
        },
        'AWS::Serverless::SimpleTable.ProvisionedThroughput' => {
          'Properties' => {
            'ReadCapacityUnits'  => { 'PrimitiveType' => 'Integer' },
            'WriteCapacityUnits' => { 'PrimitiveType' => 'Integer' }
          }
        },
        'AWS::Serverless::Function.Policy' => {
          'Properties' => {
            'PolicyDocument' => { 'PrimitiveType' => 'Json' },
            'PolicyName'     => { 'PrimitiveType' => 'String' }
          }
        }
      }
    end
  end
end
