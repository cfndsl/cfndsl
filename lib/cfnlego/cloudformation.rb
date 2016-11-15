module Cfnlego

  class CloudFormation
    TEMPLATE="#{File.dirname(__FILE__)}/cloudformation.erb"

    attr_reader :resources

    def initialize(resources)
      @description = "auto generated cloudformation cfndsl template"
      @resources   = resources
    end


    def render 
      erb = ERB.new(File.read(TEMPLATE), nil, '-')
      erb.result(binding)
    end
  end
end
