# frozen_string_literal: true

require 'spec_helper'

def read_json_fixture(filename)
  spec_dir = File.dirname(__dir__)
  filename = File.join(spec_dir, 'fixtures', filename)
  JSON.parse(File.read(filename))
end

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  it 'Serverless_Function' do
    template.Serverless_Function(:Test) do
      Handler 'fn.handler'
      Runtime 'python2.7'
      CodeUri 's3://my-code-bucket/my-function.zip'
      Description 'Creates thumbnails of uploaded images'
      MemorySize 1024
      Timeout 15
      Policies 'AmazonS3FullAccess'
      Environment(
        Variables: { TABLE_NAME: 'my-table' }
      )
      Events(
        PhotoUpload: {
          Type: 'S3',
          Properties: { Bucket: 'my-photo-bucket' }
        }
      )
    end
    expect(JSON.parse(template.to_json)).to eq(read_json_fixture('serverless-function.json'))
  end

  it 'Serverless_Api' do
    template.Serverless_Api(:Test) do
      StageName 'prod'
      DefinitionUri 'swagger.yml'
      CacheClusterEnabled false
      CacheClusterSize '512M'
      Variables(Var1: 'value1')
    end
    expect(JSON.parse(template.to_json)).to eq(read_json_fixture('serverless-api.json'))
  end
end
