# frozen_string_literal: true

require 'yaml'
require 'net/http'
require 'uri'

# Cfnlego
module  Cfnlego
  # Resource
  class Resource
    attr_reader :type, :name

    def initialize(type, name)
      @type = type
      @name = name
    end

    def attributes
      definition['Attributes']
    end

    def properties
      definition['Properties']
    end

    private

    def definition
      @definition ||= Cfnlego.resources[@type]
    rescue StandardError
      raise "unknown #{@type}, no matching definition found"
    end
  end
end
