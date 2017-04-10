require 'spec_helper'

describe CfnDsl do
  context '.method_names' do
    it 'returns an array of string method names when called without a block' do
      expect(described_class.method_names('foo')).to eq(%w[foo Foo])
    end

    it 'yields symbol method names when called with a block' do
      results = []
      described_class.method_names('foo') { |name| results << name }
      expect(results).to eq(%i[foo Foo])
    end
  end
end
