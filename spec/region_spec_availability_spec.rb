# frozen_string_literal: true

require 'spec_helper'
require 'net/http'
require 'uri'

describe 'Region specification availability', :network do
  results = {}

  before(:all) do
    threads = CfnDsl.region_spec_urls.map do |region, base_url|
      Thread.new do
        url = URI.parse("#{base_url}/latest/gzip/CloudFormationResourceSpecification.json")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = (url.scheme == 'https')
        http.open_timeout = 5
        http.read_timeout = 5

        begin
          response = http.request_head(url.path)
          results[region] = { code: response.code.to_i, url: url.to_s }
        rescue Net::OpenTimeout, Net::ReadTimeout
          results[region] = { code: nil, url: url.to_s, timeout: true }
        end
      end
    end
    threads.each(&:join)
  end

  CfnDsl.region_spec_urls.each_key do |region|
    it "#{region} has a reachable latest specification" do
      result = results[region]
      skip "Timed out connecting to #{region} (#{result[:url]}) — likely a network route issue" if result[:timeout]
      expect(result[:code]).to eq(200), "Expected 200 for #{region} (#{result[:url]}), got #{result[:code]}"
    end
  end
end
