require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  describe '#Nested_Arrays' do
    it 'ensure nested arrays are not duplicated' do
      template.DirectoryService_SimpleAD(:Test) do
        VpcSettings do
          SubnetId ['subnet-a', 'subnet-b']
        end
      end

      expect(template.to_json).to include('"SubnetIds":["subnet-a","subnet-b"]}')
      expect(template.to_json).not_to include('"SubnetIds":[["subnet-a","subnet-b"],["subnet-a","subnet-b"]]')
    end

    it 'check multiple invocations work' do
      template.DirectoryService_SimpleAD(:Test) do
        VpcSettings do
          SubnetId 'subnet-a'
          SubnetId 'subnet-b'
        end
      end

      expect(template.to_json).to include('"SubnetIds":["subnet-a","subnet-b"]}')
    end

    it 'check multiple invocation with arrays works' do
      template.DirectoryService_SimpleAD(:Test) do
        VpcSettings do
          SubnetId ['subnet-a', 'subnet-b']
          SubnetId ['subnet-c', 'subnet-d']
        end
      end

      expect(template.to_json).to include('"SubnetIds":["subnet-a","subnet-b","subnet-c","subnet-d"]')
    end

    it 'check ArtifactStore is a hash' do
      template.CodePipeline_Pipeline(:Test) do
        ArtifactStore(
          Location: 'mybucket',
          Type: 'S3'
        )
      end

      expect(template.to_json).to include('"ArtifactStore":{"Location":"mybucket","Type":"S3"}')
      expect(template.to_json).not_to include('"ArtifactStores":{"Location":"mybucket","Type":"S3"}')
      expect(template.to_json).not_to include('"ArtifactStores":[{"Location":"mybucket","Type":"S3"}]')
    end

    it 'check ArtifactStores is an array' do
      template.CodePipeline_Pipeline(:Test) do
        ArtifactStores [
          {
            ArtifactStore: {
              Type: 'S3',
              Location: 'mybucket',
              EncryptionKey: {
                Id: 'arn:goes:here',
                Type: 'KMS'
              }
            },
            Region: Ref('AWS::Region')
          }
        ]
      end

      # rubocop:disable Metrics/LineLength
      expect(template.to_json).to include('"ArtifactStores":[{"ArtifactStore":{"Type":"S3","Location":"mybucket","EncryptionKey":{"Id":"arn:goes:here","Type":"KMS"}},"Region":{"Ref":"AWS::Region"}}]')
      # rubocop:enable Metrics/LineLength
      expect(template.to_json).not_to include('"ArtifactStore":{"Location":"mybucket","Type":"S3"}')
      expect(template.to_json).not_to include('"ArtifactStores":{"Location":"mybucket","Type":"S3"}')
    end
  end
end
