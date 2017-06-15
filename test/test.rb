#!/usr/bin/env ruby
#
require 'cfndsl'

CloudFormation do
  params = {}
  external_parameters.each_pair do |key, val|
    key = key.to_s
    params[key] = val
  end
  Description 'Test Template'

  EC2_Instance('EC2Instance') do
    InstanceType params['type']
  end
end
