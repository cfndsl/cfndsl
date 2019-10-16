# frozen_string_literal: true

require 'spec_helper'

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  describe 'Nested_Arrays' do
    it 'ensure nested arrays are not duplicated' do
      template.DirectoryService_SimpleAD(:Test) do
        VpcSettings do
          SubnetId %w[subnet-a subnet-b]
        end
      end

      expect(template.to_json).to include('"SubnetIds":["subnet-a","subnet-b"]}')
      expect(template.to_json).not_to include('"SubnetIds":[["subnet-a","subnet-b"],["subnet-a","subnet-b"]]')
    end

    it 'appends entries with multiple invocations' do
      template.DirectoryService_SimpleAD(:Test) do
        VpcSettings do
          SubnetId 'subnet-a'
          SubnetId 'subnet-b'
        end
      end

      expect(template.to_json).to include('"SubnetIds":["subnet-a","subnet-b"]}')
    end

    it 'appends entries with multiple array invocations' do
      template.DirectoryService_SimpleAD(:Test) do
        VpcSettings do
          SubnetId %w[subnet-a subnet-b]
          SubnetId %w[subnet-c subnet-d]
        end
      end

      expect(template.to_json).to include('"SubnetIds":["subnet-a","subnet-b","subnet-c","subnet-d"]')
    end

    # Previous behaviour produces valid result, but appends rather than replaces (inconsistent with top level item)
    it 'appends entries when plural form is used' do
      template.DirectoryService_SimpleAD(:Test) do
        VpcSettings do
          SubnetId 'subnet-x'
          SubnetIds ['subnet-a', 'subnet-b']
        end
      end

      expect(template.to_json).to include('"SubnetIds":["subnet-a","subnet-b"]}')
    end

    it 'plural form accepts a Ref' do
      template.EC2_LaunchTemplate(:test) do
        LaunchTemplateData do
          SecurityGroupIds Ref('AListParam')
        end
      end
      expect(template.to_json).to include('"LaunchTemplateData":{"SecurityGroupIds":{"Ref":"AListParam"}')
    end
  end

  describe 'Nested Arrays With Subtype items' do
    it 'can add a subtype to a list' do
      template.EC2_SpotFleet('SpotFleet') do
        SpotFleetRequestConfigData do
          LaunchSpecification do
            ImageId 'ami-1234'
          end
        end
      end
      expect(template.to_json).to include('"LaunchSpecifications":[{"ImageId":"ami-1234"}]')
    end

    it 'can conditionally add a subtype to a list' do
      template.EC2_SpotFleet('SpotFleet') do
        SpotFleetRequestConfigData do
          # We want all the DSL goodness
          LaunchSpecification fn_if: 'ACondition' do
            ImageId 'ami-1234'
          end
        end
      end
      json = template.to_json
      expect(json).to include('"LaunchSpecifications":[{"Fn::If":["ACondition",{"ImageId":"ami-1234"},{"Ref":"AWS::NoValue"}]}]')
    end
  end

  describe 'Top level Lists' do
    it 'appends item if singular form != plural form is passed a single item' do
      template.AutoScaling_AutoScalingGroup('ASG') do
        AvailabilityZone 'region-2a'
        AvailabilityZone 'region-2b'
      end
      expect(template.to_json).to include('"AvailabilityZones":["region-2a","region-2b"]')
    end

    # Change from prior behaviour which produced an invalid result
    it 'appends multiple items if singular form != plural form is passed an array' do
      template.AutoScaling_AutoScalingGroup('ASG') do
        AvailabilityZone ['region-2a', 'region-2b']
        AvailabilityZone ['region-2c']
      end
      expect(template.to_json).to include('"AvailabilityZones":["region-2a","region-2b","region-2c"]')
    end

    it 'replaces items if plural form is passed an array' do
      template.AutoScaling_AutoScalingGroup('ASG') do
        AvailabilityZones ['region-2z']
        AvailabilityZones ['region-2a']
      end
      expect(template.to_json).to include('"AvailabilityZones":["region-2a"]')
    end

    it 'accepts a Ref in plural form' do
      template.AutoScaling_AutoScalingGroup('ASG') do
        AvailabilityZones Ref('AListParam')
      end
      expect(template.to_json).to include('"AvailabilityZones":{"Ref":"AListParam"}')
    end

    # This produces an invalid result (item not encapsulated as a List), so could be changed
    # later
    it 'replaces items if plural form is passed a single item' do
      template.AutoScaling_AutoScalingGroup('ASG') do
        AvailabilityZones 'region-xx'
        AvailabilityZones 'region-2a'
      end
      expect(template.to_json).to include('"AvailabilityZones":"region-2a"')
    end

    it 'replaces items if list attribute is singlar, and plural form is passed an array' do
      template.AutoScaling_AutoScalingGroup('ASG') do
        VPCZoneIdentifiers ['subnet-9999']
        VPCZoneIdentifiers ['subnet-1234']
      end
      expect(template.to_json).to include('"VPCZoneIdentifier":["subnet-1234"]')
    end

    it 'replaces items if list attribute is singlar, and plural form is passed an array' do
      template.AutoScaling_AutoScalingGroup('ASG') do
        VPCZoneIdentifier 'subnet-9999'
        VPCZoneIdentifiers ['subnet-1234']
      end
      expect(template.to_json).to include('"VPCZoneIdentifier":["subnet-1234"]')
    end

    it 'appends items if list attribute is singlar and passed arrays' do
      template.AutoScaling_AutoScalingGroup('ASG') do
        VPCZoneIdentifier ['subnet-9999']
        VPCZoneIdentifier ['subnet-1234']
      end
      expect(template.to_json).to include('"VPCZoneIdentifier":["subnet-9999","subnet-1234"]')
    end

    it 'appends items if plural form == singular form and passed a single item' do
      template.AutoScaling_AutoScalingGroup('ASG') do
        VPCZoneIdentifier 'subnet-9999'
        VPCZoneIdentifier 'subnet-1234'
      end
      expect(template.to_json).to include('"VPCZoneIdentifier":["subnet-9999","subnet-1234"]')
    end

    it 'can conditionally add a subtype to a list property' do
      template.SSM_MaintenanceWindowTask('Task') do
        # We want all the DSL goodness
        Target fn_if: 'ACondition' do
          Key 'AKey'
        end
      end
      expect(template.to_json).to include('"Targets":[{"Fn::If":["ACondition",{"Key":"AKey"},{"Ref":"AWS::NoValue"}]}]')
    end
  end
end
