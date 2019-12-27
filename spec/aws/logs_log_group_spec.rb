# frozen_string_literal: true

require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  describe '#Logs_LogGroup' do
    it 'supports RetentionInDays property' do
      template.Logs_LogGroup(:Test) do
        RetentionInDays 7
      end

      expect(template.to_json).to include('"RetentionInDays":7')
    end

    it 'supports LogGroupName property' do
      template.Logs_LogGroup(:Test) do
        LogGroupName 'TestLogGroup'
      end

      expect(template.to_json).to include('"LogGroupName":"TestLogGroup')
    end
  end
end
