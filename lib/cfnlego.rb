require 'yaml'
require 'erb'
require 'ruby-beautify'
require 'cfnlego/cloudformation'
require 'cfnlego/resource'
require 'cfnlego/version'
require 'net/http'
require 'uri'

JSON_URI = 'https://d2stg8d246z9di.cloudfront.net/latest/CloudFormationResourceSpecification.json'
CACHE_DIRECTORY = "#{ENV['HOME']}/.cfndsl"
CACHE_FILE      = 'resources.json'
module Cfnlego

  Dir.mkdir(CACHE_DIRECTORY) unless File.exists?(CACHE_DIRECTORY)

  def self.Resources
    content = fetch_resource_content
    supported_resources = JSON.parse(content)
    resources = []
    supported_resources['ResourceTypes'].each do |resource, value|
      resources << resource
    end
    return resources
  end

  def self.update_cache
    content = Net::HTTP.get(URI.parse(JSON_URI))
    File.open("#{CACHE_DIRECTORY}/#{CACHE_FILE}", 'w') { |file| file.write(content) }
  end
  
  def self.fetch_resource_content
    content = File.exists?("#{CACHE_DIRECTORY}/#{CACHE_FILE}") ? File.read("#{CACHE_DIRECTORY}/#{CACHE_FILE}") : Net::HTTP.get(URI.parse(JSON_URI))
    File.open("#{CACHE_DIRECTORY}/#{CACHE_FILE}", 'w') { |file| file.write(content) } unless File.exists?("#{CACHE_DIRECTORY}/#{CACHE_FILE}")
    return content
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

