module CfnDsl
  # Module for handling inconsistencies in the published resource specification from AWS
  # rubocop:disable Metrics/ModuleLength
  module Patches
    # Missing/malformed resources from the resource specification
    # rubocop:disable Metrics/MethodLength
    def self.resources
      {
        'AWS::Serverless::Function' => {
          'Properties' => {
            'Handler'                      => { 'PrimitiveType' => 'String' },
            'Runtime'                      => { 'PrimitiveType' => 'String' },
            'CodeUri'                      => { 'PrimitiveType' => 'String' },
            'FunctionName'                 => { 'PrimitiveType' => 'String' },
            'Description'                  => { 'PrimitiveType' => 'String' },
            'MemorySize'                   => { 'PrimitiveType' => 'Integer' },
            'Timeout'                      => { 'PrimitiveType' => 'Integer' },
            'Role'                         => { 'PrimitiveType' => 'String' },
            'Policies'                     => { 'Type' => 'List', 'ItemType' => 'Policy' },
            'Environment'                  => { 'PrimitiveType' => 'Json' },
            'VpcConfig'                    => { 'Type' => 'VpcConfig' },
            'Events'                       => { 'PrimitiveType' => 'Json' },
            'Tags'                         => { 'PrimitiveType' => 'Json' },
            'Tracing'                      => { 'PrimitiveType' => 'String' },
            'KmsKeyArn'                    => { 'PrimitiveType' => 'String' },
            'DeadLetterQueue'              => { 'PrimitiveType' => 'Json' },
            'DeploymentPreference'         => { 'Type' => 'DeploymentPreference' },
            'AutoPublishAlias'             => { 'PrimitiveType' => 'String' },
            'ReservedConcurrentExecutions' => { 'PrimitiveType' => 'Integer' }
          }
        },
        'AWS::Serverless::Api' => {
          'Properties' => {
            'Name'                  => { 'PrimitiveType' => 'String' },
            'StageName'             => { 'PrimitiveType' => 'String' },
            'DefinitionUri'         => { 'PrimitiveType' => 'String' },
            'DefinitionBody'        => { 'PrimitiveType' => 'Json' },
            'CacheClusterEnabled'   => { 'PrimitiveType' => 'Boolean' },
            'CacheClusterSize'      => { 'PrimitiveType' => 'String' },
            'Variables'             => { 'PrimitiveType' => 'Json' },
            'MethodSettings'        => { 'PrimitiveType' => 'Json' },
            'EndpointConfiguration' => { 'PrimitiveType' => 'String' },
            'BinaryMediaTypes'      => { 'Type' => 'List', 'PrimitiveType' => 'String' },
            'Cors'                  => { 'PrimitiveType' => 'String' }
          }
        },
        'AWS::Serverless::SimpleTable' => {
          'Properties' => {
            'PrimaryKey' => { 'Type' => 'PrimaryKey' },
            'ProvisionedThroughput' => { 'Type' => 'ProvisionedThroughput' },
            'Tags'                  => { 'PrimitiveType' => 'Json' },
            'TableName'             => { 'PrimitiveType' => 'String' }
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
    # rubocop:enable Metrics/MethodLength

    # Missing/malformed types from the resource specification
    # rubocop:disable Metrics/MethodLength
    def self.types
      {
        'AWS::EC2::LaunchTemplate.Tag' => {
          'Properties' => {
            'Value' => { 'PrimitiveType' => 'String' },
            'Key'   => { 'PrimitiveType' => 'String' }
          }
        },
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
        },
        'AWS::Serverless::Function.VpcConfig' => {
          'Properties' => {
            'SecurityGroupIds' => { 'Type' => 'List', 'PrimitiveType' => 'String' },
            'SubnetIds' => { 'Type' => 'List', 'PrimitiveType' => 'String' }
          }
        },
        'AWS::Serverless::Function.DeploymentPreference' => {
          'Properties' => {
            'Enabled' => { 'PrimitiveType' => 'Boolean' },
            'Type'    => { 'PrimitiveType' => 'String' },
            'Alarms'  => { 'Type' => 'List', 'PrimitiveType' => 'String' },
            'Hooks'   => { 'Type' => 'List', 'PrimitiveType' => 'String' }
          }
        }
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
  # rubocop:enable Metrics/ModuleLength
end
