# frozen_string_literal: true

require 'spec_helper'

describe CfnDsl::Plurals do
  context '.pluralize' do
    it 'pluralizes methods from the list' do
      expect(described_class.pluralize(:SecurityGroupIngress)).to eq('SecurityGroupIngress')
    end

    it 'pluralizes other methods' do
      expect(described_class.pluralize(:StageKey)).to eq('StageKeys')
    end
  end

  context '.singularize' do
    it 'singularizes methods from the list' do
      expect(described_class.singularize(:SecurityGroupIngress)).to eq('SecurityGroupIngress')
    end

    it 'singularizes other methods' do
      expect(described_class.singularize(:StageKeys)).to eq('StageKey')
    end
  end
end
