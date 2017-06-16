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
        },
        'AWS::EC2::VPNGatewayConnection' => {
          'Properties' => {
            'Type' => { 'PrimitiveType' => 'String' },
            'Tags' => { 'Type' => 'List', 'ItemType' => 'Tag' }
          }
        },
        'AWS::EC2::EIPAssociation' => {
          'Properties' => {
            'AllocationId'       => { 'PrimitiveType' => 'String' },
            'EIP'                => { 'PrimitiveType' => 'String' },
            'InstanceId'         => { 'PrimitiveType' => 'String' },
            'NetworkInterfaceId' => { 'PrimitiveType' => 'String' },
            'PrivateIpAddress'   => { 'PrimitiveType' => 'String' }
          }
        },
        'AWS::Config::ConfigurationRecorder' => {
          'Properties' => {
            'Name'           => { 'PrimitiveType' => 'String' },
            'RecordingGroup' => { 'Type' => 'RecordingGroup' },
            'RoleARN'        => { 'PrimitiveType' => 'String' }
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
        },
        'AWS::Cognito::IdentityPoolRoleAttachment.RulesConfigurationType' => {
          'Properties' => {
            'Rules' => { 'Type' => 'List', 'ItemType' => 'MappingRule' }
          }
        }
      }
    end
  end
end
