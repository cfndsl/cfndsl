# frozen_string_literal: true

module CfnDsl
  # Module for handling inconsistencies in the published resource specification from AWS
  # rubocop:disable Metrics/ModuleLength
  module Patches
    # Missing/malformed resources from the resource specification
    # rubocop:disable Metrics/MethodLength
    def self.resources
      {
        'AWS::EC2::VPCEndpoint' => {
          'Properties' => {
            'PolicyDocument' => { 'PrimitiveType' => 'Json' },
            'PrivateDnsEnabled' => { 'PrimitiveType' => 'Boolean' },
            'RouteTableIds' => { 'PrimitiveType' => 'String' },
            'SecurityGroupIds' => { 'PrimitiveType' => 'String' },
            'ServiceName' => { 'PrimitiveType' => 'String' },
            'SubnetIds' => { 'PrimitiveType' => 'String' },
            'VpcEndpointType' => { 'PrimitiveType' => 'String' },
            'VpcId' => { 'PrimitiveType' => 'String' }
          }
        },
        'AWS::CloudWatch::Alarm' => {
          'Properties' => {
            'ActionsEnabled' => { 'PrimitiveType' => 'Boolean' },
            'AlarmActions' => { 'Type' => 'List', 'PrimitiveType' => 'String' },
            'AlarmDescription' => { 'PrimitiveType' => 'String' },
            'AlarmName' => { 'PrimitiveType' => 'String' },
            'ComparisonOperator' => { 'PrimitiveType' => 'String' },
            'DatapointsToAlarm' => { 'PrimitiveType' => 'Integer' },
            'Dimensions' => { 'Type' => 'List', 'ItemType' => 'Dimension' },
            'EvaluateLowSampleCountPercentile' => { 'PrimitiveType' => 'String' },
            'EvaluationPeriods' => { 'PrimitiveType' => 'Integer' },
            'ExtendedStatistic' => { 'PrimitiveType' => 'String' },
            'InsufficientDataActions' => { 'Type' => 'List', 'PrimitiveType' => 'String' },
            'Metrics' => { 'Type' => 'List', 'PrimitiveType' => 'Json' },
            'MetricName' => { 'PrimitiveType' => 'String' },
            'Namespace' => { 'PrimitiveType' => 'String' },
            'OKActions' => { 'Type' => 'List', 'PrimitiveType' => 'String' },
            'Period' => { 'PrimitiveType' => 'Integer' },
            'Statistic' => { 'PrimitiveType' => 'String' },
            'Threshold' => { 'PrimitiveType' => 'Double' },
            'TreatMissingData' => { 'PrimitiveType' => 'String' },
            'Unit' => { 'PrimitiveType' => 'String' }
          }
        },
        'AWS::Serverless::Function' => {
          'Properties' => {
            'Tags': { 'ItemType' => 'Tag', 'Type': 'List' },
            'Handler' => { 'PrimitiveType' => 'String' },
            'Runtime' => { 'PrimitiveType' => 'String' },
            'CodeUri' => { 'PrimitiveType' => 'String' },
            'InlineCode' => { 'PrimitiveType' => 'String' },
            'FunctionName' => { 'PrimitiveType' => 'String' },
            'Description' => { 'PrimitiveType' => 'String' },
            'MemorySize' => { 'PrimitiveType' => 'Integer' },
            'Timeout' => { 'PrimitiveType' => 'Integer' },
            'Role' => { 'PrimitiveType' => 'String' },
            'Policies' => { 'Type' => 'List', 'ItemType' => 'Policy' },
            'Environment' => { 'PrimitiveType' => 'Json' },
            'VpcConfig' => { 'Type' => 'VpcConfig' },
            'Events' => { 'PrimitiveType' => 'Json' },
            'Tags' => { 'PrimitiveType' => 'Json' },
            'Tracing' => { 'PrimitiveType' => 'String' },
            'KmsKeyArn' => { 'PrimitiveType' => 'String' },
            'DeadLetterQueue' => { 'PrimitiveType' => 'Json' },
            'DeploymentPreference' => { 'Type' => 'DeploymentPreference' },
            'AutoPublishAlias' => { 'PrimitiveType' => 'String' },
            'ReservedConcurrentExecutions' => { 'PrimitiveType' => 'Integer' }
          }
        },
        'AWS::IAM::Role' => {
          'Properties' => {
            'Tags': { 'ItemType' => 'Tag', 'Type': 'List' },
            'AssumeRolePolicyDocument'=> { 'PrimitiveType' => 'Json' },
            'ManagedPolicyArns'=> { 'PrimitiveItemType'=> 'String', 'Type'=> 'List' },
            'Path'=> { 'PrimitiveType' => 'String' },
            'Policies'=> { 'ItemType'=> 'Policy','Type'=> 'List' },
            'RoleName'=> { 'PrimitiveType' => 'String' }
          }
        },
        'AWS::Serverless::Api' => {
          'Properties' => {
            'Name' => { 'PrimitiveType' => 'String' },
            'StageName' => { 'PrimitiveType' => 'String' },
            'DefinitionUri' => { 'PrimitiveType' => 'String' },
            'DefinitionBody' => { 'PrimitiveType' => 'Json' },
            'CacheClusterEnabled' => { 'PrimitiveType' => 'Boolean' },
            'CacheClusterSize' => { 'PrimitiveType' => 'String' },
            'Variables' => { 'PrimitiveType' => 'Json' },
            'MethodSettings' => { 'PrimitiveType' => 'Json' },
            'EndpointConfiguration' => { 'PrimitiveType' => 'String' },
            'BinaryMediaTypes' => { 'Type' => 'List', 'PrimitiveType' => 'String' },
            'Cors' => { 'PrimitiveType' => 'String' }
          }
        },
        'AWS::Serverless::SimpleTable' => {
          'Properties' => {
            'PrimaryKey' => { 'Type' => 'PrimaryKey' },
            'ProvisionedThroughput' => { 'Type' => 'ProvisionedThroughput' },
            'Tags' => { 'PrimitiveType' => 'Json' },
            'TableName' => { 'PrimitiveType' => 'String' }
          }
        },
        'AWS::SSM::Parameter' => {
          'Properties' => {
            'Name' => { 'PrimitiveType' => 'String' },
            'Description' => { 'PrimitiveType' => 'String' },
            'Type' => { 'PrimitiveType' => 'String' },
            'Value' => { 'PrimitiveType' => 'String' }
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
            'Key' => { 'PrimitiveType' => 'String' }
          }
        },
        'AWS::EC2::SpotFleet.Tag' => {
          'Properties' => {
            'Value' => { 'PrimitiveType' => 'String' },
            'Key' => { 'PrimitiveType' => 'String' }
          }
        },
        'AWS::EC2::CapacityReservation.Tag' => {
          'Properties' => {
            'Value' => { 'PrimitiveType' => 'String' },
            'Key' => { 'PrimitiveType' => 'String' }
          }
        },
        'AWS::DLM::LifecyclePolicy.Tag' => {
          'Properties' => {
            'Value' => { 'PrimitiveType' => 'String' },
            'Key' => { 'PrimitiveType' => 'String' }
          }
        },
        'AWS::Api::GatewayDeployment.Tag' => {
          'Properties' => {
            'Value' => { 'PrimitiveType' => 'String' },
            'Key' => { 'PrimitiveType' => 'String' }
          }
        },
        'AWS::EC2::ClientVpnEndpoint.Tag' => {
          'Properties' => {
            'Value' => { 'PrimitiveType' => 'String' },
            'Key' => { 'PrimitiveType' => 'String' }
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
            'ReadCapacityUnits' => { 'PrimitiveType' => 'Integer' },
            'WriteCapacityUnits' => { 'PrimitiveType' => 'Integer' }
          }
        },
        'AWS::Serverless::Function.Policy' => {
          'Properties' => {
            'PolicyDocument' => { 'PrimitiveType' => 'Json' },
            'PolicyName' => { 'PrimitiveType' => 'String' }
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
            'Type' => { 'PrimitiveType' => 'String' },
            'Alarms' => { 'Type' => 'List', 'PrimitiveType' => 'String' },
            'Hooks' => { 'Type' => 'List', 'PrimitiveType' => 'String' }
          }
        }
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
  # rubocop:enable Metrics/ModuleLength
end
