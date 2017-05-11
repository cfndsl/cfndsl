module CfnDsl
  # Helper module for bridging the gap between a static types file included in the repo
  # and dynamically generating the types directly from the AWS specification
  # rubocop:disable Metrics/ModuleLength
  module Specification
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity
    def self.extract_resources(spec)
      spec.each_with_object({}) do |(resource_name, resource_info), resources|
        properties = resource_info['Properties'].each_with_object({}) do |(property_name, property_info), extracted|
          # some json incorrectly labelled as Type -> Json instead of PrimitiveType
          # also, AWS now has the concept of Map which cfndsl had never defined
          if property_info['Type'] == 'Map' || property_info['Type'] == 'Json'
            property_type = 'Json'
          elsif property_info['PrimitiveType']
            property_type = property_info['PrimitiveType']
          elsif property_info['PrimitiveItemType']
            property_type = Array(property_info['PrimitiveItemType'])
          elsif property_info['ItemType']
            # Tag is a reused type, but not quite primitive
            # and not all resources use the general form
            property_type = if property_info['ItemType'] == 'Tag'
                              'Tag'
                            else
                              Array(resource_name.split('::').join + property_info['ItemType'])
                            end
          elsif property_info['Type']
            # Special types (defined below) are joined with their parent
            # resource name for uniqueness and connection
            property_type = resource_name.split('::').join + property_info['Type']
          else
            warn "could not extract type from #{resource_name}"
          end
          extracted[property_name] = property_type
          extracted
        end
        resources[resource_name] = { 'Properties' => properties }
        resources
      end
    end

    def self.extract_types(spec)
      primitive_types = {
        'String'    => 'String',
        'Boolean'   => 'Boolean',
        'Json'      => 'Json',
        'Integer'   => 'Integer',
        'Number'    => 'Number',
        'Double'    => 'Double',
        'Timestamp' => 'Timestamp',
        'Long'      => 'Long'
      }
      spec.each_with_object(primitive_types) do |(property_name, property_info), types|
        # In order to name things uniquely and allow for connections
        # we extract the resource name from the property
        # AWS::IAM::User.Policy becomes AWSIAMUserPolicy
        root_resource = property_name.match(/(.*)\./)
        root_resource_name = root_resource ? root_resource[1].gsub(/::/, '') : property_name
        property_name = property_name.gsub(/::|\./, '')
        next unless property_info['Properties']
        properties = property_info['Properties'].each_with_object({}) do |(nested_prop_name, nested_prop_info), extracted|
          if nested_prop_info['Type'] == 'Map' || nested_prop_info['Type'] == 'Json'
            # The Map type and the incorrectly labelled Json type
            nested_prop_type = 'Json'
          elsif nested_prop_info['PrimitiveType']
            nested_prop_type = nested_prop_info['PrimitiveType']
          elsif nested_prop_info['PrimitiveItemType']
            nested_prop_type = Array(nested_prop_info['PrimitiveItemType'])
          elsif nested_prop_info['ItemType']
            nested_prop_type = root_resource_name + nested_prop_info['ItemType']
          elsif nested_prop_info['Type']
            nested_prop_type = root_resource_name + nested_prop_info['Type']
          else
            warn "could not extract type from #{property_name}"
          end
          extracted[nested_prop_name] = nested_prop_type
          extracted
        end
        types[property_name] = properties
        types
      end
    end

    # Missing/malformed resources from the resource specification
    def self.resources_patch
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
        }
      }
    end

    # Missing/malformed types from the resource specification
    def self.types_patch
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

    def self.extract_from_resource_spec!
      spec_file = JSON.parse File.read(CfnDsl.specification_file)
      resources = extract_resources spec_file['ResourceTypes'].merge(resources_patch)
      types = extract_types spec_file['PropertyTypes'].merge(types_patch)
      { 'Resources' => resources, 'Types' => types }
    end
  end
end
