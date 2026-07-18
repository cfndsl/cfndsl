# frozen_string_literal: true

require 'spec_helper'

describe CfnDsl do
  describe '.spec_url_for_region' do
    it 'builds the correct URL for a CloudFront-backed region' do
      url = CfnDsl.spec_url_for_region('eu-west-1', version: '255.0.0')
      expect(url).to eq('https://d3teyb21fexa9r.cloudfront.net/255.0.0/gzip/CloudFormationResourceSpecification.json')
    end

    it 'builds the correct URL for an S3-backed region' do
      url = CfnDsl.spec_url_for_region('af-south-1', version: 'latest')
      expect(url).to eq('https://cfn-resource-specifications-af-south-1-prod.s3.af-south-1.amazonaws.com/latest/gzip/CloudFormationResourceSpecification.json')
    end

    it 'builds the correct URL for the default region (us-east-1)' do
      url = CfnDsl.spec_url_for_region('us-east-1', version: '7.1.0')
      expect(url).to eq('https://d1uauaxba7bl26.cloudfront.net/7.1.0/gzip/CloudFormationResourceSpecification.json')
    end

    it 'raises CfnDsl::Error for an unsupported region' do
      expect { CfnDsl.spec_url_for_region('mars-west-1', version: 'latest') }
        .to raise_error(CfnDsl::Error, /Unsupported region 'mars-west-1'/)
    end
  end

  describe '.supported_spec_regions' do
    it 'returns a sorted array of 35 region codes' do
      regions = CfnDsl.supported_spec_regions
      expect(regions).to be_an(Array)
      expect(regions).to eq(regions.sort)
      expect(regions.size).to eq(35)
    end

    it 'includes well-known regions' do
      regions = CfnDsl.supported_spec_regions
      expect(regions).to include('us-east-1', 'us-west-2', 'eu-west-1', 'ap-southeast-2')
    end
  end

  describe '.update_specification_file' do
    let(:tmpdir) { Dir.mktmpdir }
    let(:tmpfile) { File.join(tmpdir, 'spec.json') }
    let(:spec_content) { '{"ResourceSpecificationVersion":"255.0.0","ResourceTypes":{},"PropertyTypes":{}}' }

    before do
      mock_io = double('io', read: spec_content)
      mock_uri = double('uri', open: mock_io)
      allow(URI).to receive(:parse).and_return(mock_uri)
    end

    after { FileUtils.rm_rf(tmpdir) }

    context 'with explicit region' do
      it 'uses the region-specific URL' do
        result = CfnDsl.update_specification_file(file: tmpfile, version: '255.0.0', region: 'eu-west-1')
        expect(result[:url]).to eq('https://d3teyb21fexa9r.cloudfront.net/255.0.0/gzip/CloudFormationResourceSpecification.json')
        expect(result[:region]).to eq('eu-west-1')
      end

      it 'writes the spec content to the file' do
        CfnDsl.update_specification_file(file: tmpfile, version: '255.0.0', region: 'eu-west-1')
        expect(File.exist?(tmpfile)).to be true
        parsed = JSON.parse(File.read(tmpfile))
        expect(parsed['ResourceSpecificationVersion']).to eq('255.0.0')
      end

      it 'resolves version from content when version is latest' do
        result = CfnDsl.update_specification_file(file: tmpfile, version: 'latest', region: 'us-east-1')
        expect(result[:version]).to eq('255.0.0')
      end
    end

    context 'without region (defaults to us-east-1)' do
      it 'uses the us-east-1 URL' do
        result = CfnDsl.update_specification_file(file: tmpfile, version: '255.0.0')
        expect(result[:url]).to eq('https://d1uauaxba7bl26.cloudfront.net/255.0.0/gzip/CloudFormationResourceSpecification.json')
        expect(result[:region]).to eq('us-east-1')
      end
    end
  end
end
