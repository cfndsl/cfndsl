# frozen_string_literal: true

require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  describe 'Bogus Properties that are type List' do
    it 'fixes Resource property type to a List of its item type' do
      template.LakeFormation_DataLakeSettings('lake') do
        Admin { DataLakePrincipalIdentifier 'principal' }
      end
      expect(template.to_json).to include('"Type":"AWS::LakeFormation::DataLakeSettings","Properties":{"Admins":[{"DataLakePrincipalIdentifier":"principal"')
    end

    it 'fixes Subtype property Tags to a list of Tags' do
      template.AppSync_GraphQLApi('api') do
        Tag do
          Key 'tagkey'
          Value 'tagvalue'
        end
      end
      expect(template.to_json).to include('"Properties":{"Tags":[{"Key":"tagkey","Value":"tagvalue"}]}}}')
    end

    it 'fixes Subtype property type to a List of its item type' do
      template.Glue_SecurityConfiguration('glue') do
        EncryptionConfiguration do
          S3Encryption { S3EncryptionMode 'mode' }
        end
      end
      expect(template.to_json).to include('"EncryptionConfiguration":{"S3Encryptions":[{"S3EncryptionMode":"mode"}]}}}}}')
    end
  end
end
