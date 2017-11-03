require 'yaml'
require 'erb'
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
    supported_resources['ResourceTypes'].each_key do |resource|
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
      return Cfnlego::CloudFormation.new(resources).render
    rescue RuntimeError => e
      warn "Error: #{e.message}"
    end
    nil
  end
end
