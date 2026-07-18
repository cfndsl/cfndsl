# frozen_string_literal: true

require_relative 'version'
require 'json'
require 'fileutils'

# Global variables to adjust CfnDsl behavior
module CfnDsl
  class Error < StandardError
  end

  module_function

  LOCAL_SPEC_FILE = File.expand_path('aws/resource_specification.json', __dir__)
  REGION_SPEC_URLS_FILE = File.expand_path('aws/region_spec_urls.json', __dir__)

  SPEC_PATH_SUFFIX = '%<version>s/gzip/CloudFormationResourceSpecification.json'
  DEFAULT_SPEC_REGION = 'us-east-1'

  def region_spec_urls
    @region_spec_urls ||= JSON.parse(File.read(REGION_SPEC_URLS_FILE)).tap { |h| h.delete('_source') }.freeze
  end

  def disable_deep_merge
    @disable_deep_merge = true
  end

  def disable_deep_merge?
    @disable_deep_merge
  end

  def specification_file=(file)
    raise Error, "Specification #{file} does not exist" unless File.exist?(file)

    @specification_file = file
  end

  # @overload specification_file()
  # @return [String] the specification file name
  # @overload specification_file(file)
  # @deprecated Use specification_file= to override the specification file
  def specification_file(file = nil)
    self.specification_file = file if file
    @specification_file ||= user_specification_file
    @specification_file = LOCAL_SPEC_FILE unless File.exist?(@specification_file)
    @specification_file
  end

  def user_specification_file
    File.join(ENV['HOME'], '.cfndsl/resource_specification.json')
  end

  # Build the full specification URL for a given region and version
  #
  # @param region [String] AWS region code
  # @param version [String] specification version or 'latest'
  # @return [String] full URL to the CloudFormation resource specification
  def spec_url_for_region(region, version:)
    base_url = region_spec_urls.fetch(region) do
      raise Error, "Unsupported region '#{region}'. Use CfnDsl.supported_spec_regions for a list of supported regions."
    end
    "#{base_url}/#{format(SPEC_PATH_SUFFIX, version: version)}"
  end

  # List all supported regions for spec downloads
  #
  # @return [Array<String>] sorted list of supported region codes
  def supported_spec_regions
    region_spec_urls.keys.sort
  end

  def update_specification_file(file: user_specification_file, version: nil, region: nil)
    require 'open-uri'
    version ||= 'latest'
    region ||= DEFAULT_SPEC_REGION
    FileUtils.mkdir_p File.dirname(file)
    url = spec_url_for_region(region, version: version)
    content = URI.parse(url).open.read
    version = JSON.parse(content)['ResourceSpecificationVersion'] if version == 'latest'
    File.open(file, 'w') { |f| f.puts content }
    { file: file, version: version, url: url, region: region }
  rescue StandardError
    raise "Failed updating specification file #{file} from #{url}"
  end

  def additional_specs(*specs)
    @additional_specs ||= Dir[File.expand_path('aws/patches/*.spec.json', __dir__)]
    @additional_specs.concat(specs.flatten)
  end

  def specification_patches(*patches)
    # TODO: This is not capturing all the files in patches dir!
    @patches ||= Dir[File.expand_path('aws/patches/*patch.json', __dir__)]
    @patches.concat(patches.flatten)
  end

  def reserved_items
    %w[Resource Rule Parameter Output].freeze
  end
end
