require 'yaml'
require 'net/http'
require 'uri'

module  Cfnlego
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
      content = Cfnlego.fetch_resource_content
      datainput = JSON.load(content)
      data = datainput['PropertyTypes']
      if data[@type]
        @definition ||= data[@type]
      else
        raise RuntimeError, "unknown #{@type}, no matching definition found"
      end
    end
  end
end
