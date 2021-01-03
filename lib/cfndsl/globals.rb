# frozen_string_literal: true

require_relative 'version'
require 'fileutils'

# Global variables to adjust CfnDsl behavior
module CfnDsl
  class Error < StandardError
  end

  module_function

  AWS_SPECIFICATION_URL = 'https://d1uauaxba7bl26.cloudfront.net/%<version>s/gzip/CloudFormationResourceSpecification.json'
  LOCAL_SPEC_FILE = File.expand_path('aws/resource_specification.json', __dir__)

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

  def update_specification_file(file: user_specification_file, version: nil)
    require 'open-uri'
    version ||= 'latest'
    FileUtils.mkdir_p File.dirname(file)
    url = format(AWS_SPECIFICATION_URL, version: version)
    content = URI.parse(url).open.read
    version = JSON.parse(content)['ResourceSpecificationVersion'] if version == 'latest'
    File.open(file, 'w') { |f| f.puts content }
    { file: file, version: version, url: url }
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
