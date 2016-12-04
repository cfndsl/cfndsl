require 'yaml'
require 'erb'
require 'ruby-beautify'
require 'cfnlego/cloudformation'
require 'cfnlego/resource'
require 'cfnlego/version'
require 'net/http'
require 'uri'

JSON_URI        = 'https://d1uauaxba7bl26.cloudfront.net/latest/CloudFormationResourceSpecification.json'.freeze
CACHE_DIRECTORY = "#{ENV['HOME']}/.cfndsl".freeze
CACHE_FILE      = 'resources.json'.freeze
# Cfnlego
module Cfnlego
  Dir.mkdir(CACHE_DIRECTORY) unless File.exist?(CACHE_DIRECTORY)

  def self.Resources
    content = fetch_resource_content
    supported_resources = JSON.parse(content)
    resources = []
    supported_resources['ResourceTypes'].each do |resource, _value|
      resources << resource
    end
    resources
  end

  def self.update_cache
    content = Net::HTTP.get(URI.parse(JSON_URI))
    File.open("#{CACHE_DIRECTORY}/#{CACHE_FILE}", 'w') { |file| file.write(content) }
  end

  def self.fetch_resource_content
    content = File.exist?("#{CACHE_DIRECTORY}/#{CACHE_FILE}") ? File.read("#{CACHE_DIRECTORY}/#{CACHE_FILE}") : Net::HTTP.get(URI.parse(JSON_URI))
    File.open("#{CACHE_DIRECTORY}/#{CACHE_FILE}", 'w') { |file| file.write(content) } unless File.exist?("#{CACHE_DIRECTORY}/#{CACHE_FILE}")
    content
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
