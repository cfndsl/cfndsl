# frozen_string_literal: true

require 'yaml'
require 'erb'
require 'net/http'
require 'uri'
require_relative 'cfnlego/cloudformation'
require_relative 'cfnlego/resource'
require_relative 'specification'

# Cfnlego
module Cfnlego
  def self.resources
    @resources ||= CfnDsl::Specification.load_file.resources
  end

  def self.run(options)
    resources =
      options[:resources].each_with_object([]) do |r, list|
        /(.*),(.*)/.match(r) do |m|
          type = m[1]
          name = m[2]
          list << Cfnlego::Resource.new(type, name)
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
