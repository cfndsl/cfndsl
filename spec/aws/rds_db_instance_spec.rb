# frozen_string_literal: true

require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  describe '#RDS_DBInstance' do
    it 'supports MonitoringInterval property' do
      template.RDS_DBInstance(:Test) do
        MonitoringInterval 1
      end

      expect(template.to_json).to include('"MonitoringInterval":1')
    end

    it 'supports MonitoringRoleArn property' do
      template.RDS_DBInstance(:Test) do
        MonitoringRoleArn 'arn:aws:iam:123456789012:role/emaccess'
      end

      expect(template.to_json).to include('"MonitoringRoleArn":"arn:aws:iam:123456789012:role/emaccess"')
    end
  end
end
