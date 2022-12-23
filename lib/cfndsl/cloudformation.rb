# frozen_string_literal: true

require_relative 'globals'
require_relative 'external_parameters'
require_relative 'aws/cloud_formation_template'

# CfnDsl
module CfnDsl
  # This function handles the eval of the template file and returns the
  # results. It does this with a ruby "eval", but it builds up a customized
  # binding environment before it calls eval. The environment can be
  # customized by passing a list of customizations in the extras parameter.
  #
  # These customizations are expressed as an array of pairs of
  # (type,filename). They are evaluated in the order they appear in the
  # extras array. The types are as follows
  #
  # :yaml - the second element is treated as a file name, which is loaded
  #         as a yaml file. The yaml file should contain a top level
  #         dictionary. Each of the keys of the top level dictionary is
  #         used as a local variable in the evalation context.
  #
  # :json - the second element is treated as a file name, which is loaded
  #         as a json file. The yaml file should contain a top level
  #         dictionary. Each of the keys of the top level dictionary is
  #         used as a local variable in the evalation context.
  #
  # :raw  - the second element is treated as a ruby statement and is
  #         evaluated in the binding context, similar to the contents of
  #         a ruby file.
  #
  # Note that the order is important, as later extra sections can overwrite
  # or even undo things that were done by earlier sections.

  def self.eval_file_with_extras(filename, extras = [], logstream = nil)
    b = binding
    params = CfnDsl::ExternalParameters.refresh!
    extras.each do |type, file|
      case type
      when :yaml, :json
        klass_name = type.to_s.upcase
        logstream.puts("Loading #{klass_name} file #{file}") if logstream
        params.load_file file
      when :raw
        file_parts = file.split('=')
        case file_parts[1].downcase
        when 'true'
          params.set_param(file_parts[0], true)
        when 'false'
          params.set_param(file_parts[0], false)
        else
          params.set_param(*file.split('='))
        end
      end
    end

    params.each_pair do |k, v|
      b.eval "#{k} = #{v.inspect}"
    end

    logstream.puts("Loading template file #{filename}") if logstream
    b.eval(File.read(filename), filename)
  end

  # Syntactic Sugar for embedded ruby usage
  # @example
  # require `cfndsl`
  #
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
  #
  module CloudFormation
    # Include all the fun JSONABLE stuff and Fn* functions so you can use them
    # in local methods
    include Functions

    def CloudFormation(description = nil, &block)
      CloudFormationTemplate.new(description, &block)
    end
  end
end

# Main function to build and validate
# @return [CfnDsl::CloudFormationTemplate]
# @raise [CfnDsl::Error] if the block does not generate a valid template
def CloudFormation(description = nil, &block)
  CfnDsl::CloudFormationTemplate.new(description).declare(&block).validate
end
