# frozen_string_literal: true

require 'spec_helper'
describe DeepMerge do
  source = { key1: { keya1: 1, keya2: 2 }, key2: [1, 2] }
  let(:merged_hash) { source.deep_merge!(key1: { keya1: '1a', keya3: 3 }, key2: [2, 3]) }

  context 'deep_merge' do
    it 'merges correctly' do
      test_hash = { key1: { keya1: '1a', keya2: 2, keya3: 3 }, key2: [1, 2, 3] }
      expect(merged_hash).to eq test_hash
    end
  end
end
