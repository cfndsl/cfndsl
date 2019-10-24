# frozen_string_literal: true

require 'open-uri'

# Global variables to adjust CfnDsl behavior
module CfnDsl
  module_function

  AWS_SPECIFICATION_URL = 'https://d1uauaxba7bl26.cloudfront.net/%<version>s/gzip/CloudFormationResourceSpecification.json'
  LOCAL_SPEC_FILE = File.expand_path('aws/resource_specification.json', __dir__)

  def disable_deep_merge
    @disable_deep_merge = true
  end

  def disable_deep_merge?
    @disable_deep_merge
  end

  def specification_file(file = nil)
    @specification_file = file if file
    @specification_file ||= File.join(ENV['HOME'], '.cfndsl/resource_specification.json')
    @specification_file
  end

  def update_specification_file(file: nil, version: nil)
    version ||= 'latest'
    file ||= specification_file(file)
    FileUtils.mkdir_p File.dirname(file)
    url = format(AWS_SPECIFICATION_URL, version: version)
    content = URI.parse(url).open.read
    version = JSON.parse(content)['ResourceSpecificationVersion'] if version == 'latest'
    File.open(file, 'w') { |f| f.puts content }
    { file: file, version: version, url: url }
  rescue StandardError
    raise "Failed updating specification file #{file} from #{url}"
  end

  def reserved_items
    %w[Resource Rule Parameter Output].freeze
  end
end
