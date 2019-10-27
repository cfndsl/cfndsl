# frozen_string_literal: true

require 'cfndsl/aws/cloud_formation_template'

module CfnDsl
  # Syntactic Sugar for embedded ruby usage
  # @example
  # require `cfndsl/aws/cloudformation`
  # class Builder
  #    include CfnDsl::CloudFormation
  #
  #    def build_template()
  #       template = CloudFormation('ANewTemplate')
  #       a_param = template.Parameter('AParam')
  #       a_param.Type('String')
  #       return template
  #    end
  #
  #    def map_instance_type(instance_type)
  #      # logic to auto convert instance types to latest available etc..
  #      FnFindInMap("InstanceTypeConversion",Ref('AWS::Region'),instance_type)
  #    end
  #
  #    # templates can be passed around to other methods/classes
  #    def add_instance(template, instance_type)
  #      ec2 = template.EC2_Instance(:myInstance)
  #      ec2.InstanceType(map_instance_type(instance_type))
  #      # Alteratively with DSL block syntax
  #      this = self  # declare block is eval for the model instance so need to keep a reference
  #      template.declare do
  #        EC2_Instance(:myInstance) do
  #           InstanceType this.map_instance_type(instance_type)
  #        end
  #      end
  #   end
  #
  #   def generate(template,pretty: false)
  #      valid = template.validate
  #      pretty ? valid.to_json : JSON.pretty_generate(valid)
  #   end
  # end
  module CloudFormation
    # Include all the fun JSONABLE stuff and Fn* functions
    include Functions

    def CloudFormation(description = nil, &block)
      CloudFormationTemplate.new(description, &block)
    end
  end
end
