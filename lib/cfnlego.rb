require 'yaml'
require 'erb'
require 'ruby-beautify'
require 'cfnlego/cloudformation'
require 'cfnlego/resource'
require 'net/http'
require 'uri'

# Cfnlego
module Cfnlego
  def self.Resources
    content = fetch_resource_content
    supported_resources = JSON.parse(content)
    resources = []
    supported_resources['ResourceTypes'].each do |resource, _value|
      resources << resource
    end
    resources
  end

  def self.fetch_resource_content
    File.read(CfnDsl.specification_file)
  end

  def self.run(options)
    # Constructure Resources
    resources = []
    options[:resources].each do |r|
      /(.*),(.*)/.match(r) do |m|
        type = m[1]
        name = m[2]
        resources << Cfnlego::Resource.new(type, name)
      end
    end

    begin
      puts RubyBeautify.pretty_string Cfnlego::CloudFormation.new(resources).render,
                                      indent_token: options[:indent_token],
                                      indent_count: options[:indent_count]
    rescue RuntimeError => e
      $stderr.puts "Error: #{e.message}"
    end
  end
end
