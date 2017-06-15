require 'cfndsl/errors'
require 'cfndsl/ref_check'
require 'cfndsl/json_serialisable_object'

module CfnDsl
  # These functions are available anywhere inside
  # a block for a JSONable object.
  module Functions
    # Equivalent to the CloudFormation template built in function Ref
    def Ref(value)
      RefDefinition.new(value)
    end

    # Equivalent to the CloudFormation template built in function Fn::Base64
    def FnBase64(value)
      Fn.new('Base64', value)
    end

    # Equivalent to the CloudFormation template built in function Fn::FindInMap
    def FnFindInMap(map, key, value)
      Fn.new('FindInMap', [map, key, value])
    end

    # Equivalent to the CloudFormation template built in function Fn::GetAtt
    def FnGetAtt(logical_resource, attribute)
      Fn.new('GetAtt', [logical_resource, attribute])
    end

    # Equivalent to the CloudFormation template built in function Fn::GetAZs
    def FnGetAZs(region)
      Fn.new('GetAZs', region)
    end

    # Equivalent to the CloudFormation template built in function Fn::Join
    def FnJoin(string, array)
      Fn.new('Join', [string, array])
    end

    # Equivalent to the CloudFormation template built in function Fn::Split
    def FnSplit(string, array)
      Fn.new('Split', [string, array])
    end

    # Equivalent to the CloudFormation template built in function Fn::And
    def FnAnd(array)
      if !array || array.count < 2 || array.count > 10
        raise 'The array passed to Fn::And must have at least 2 elements and no more than 10'
      end
      Fn.new('And', array)
    end

    # Equivalent to the Cloudformation template built in function Fn::Equals
    def FnEquals(value1, value2)
      Fn.new('Equals', [value1, value2])
    end

    # Equivalent to the Cloudformation template built in function Fn::If
    def FnIf(condition_name, true_value, false_value)
      Fn.new('If', [condition_name, true_value, false_value])
    end

    # Equivalent to the Cloudformation template built in function Fn::Not
    def FnNot(value)
      if value.is_a?(Array)
        Fn.new('Not', value)
      else
        Fn.new('Not', [value])
      end
    end

    # Equivalent to the CloudFormation template built in function Fn::Or
    def FnOr(array)
      if !array || array.count < 2 || array.count > 10
        raise 'The array passed to Fn::Or must have at least 2 elements and no more than 10'
      end
      Fn.new('Or', array)
    end

    # Equivalent to the CloudFormation template built in function Fn::Select
    def FnSelect(index, array)
      Fn.new('Select', [index, array])
    end

    # Equivalent to the CloudFormation template built in function Fn::Sub
    def FnSub(string, substitutions = nil)
      raise ArgumentError, 'The first argument passed to Fn::Sub must be a string' unless string.is_a? String
      if substitutions
        raise ArgumentError, 'The second argument passed to Fn::Sub must be a Hash' unless substitutions.is_a? Hash
        Fn.new('Sub', [string, substitutions])
      else
        Fn.new('Sub', string)
      end
    end

    # Equivalent to the CloudFormation template built in function Fn::ImportValue
    def FnImportValue(value)
      Fn.new('ImportValue', value)
    end
  end

  # This is the base class for just about everything useful in the
  # DSL. It knows how to turn DSL Objects into the corresponding
  # json, and it lets you create new built in function objects
  # from inside the context of a dsl object.
  class JSONable
    include Functions
    extend Functions
    include RefCheck

    def self.external_parameters
      CfnDsl::ExternalParameters.current
    end

    def external_parameters
      self.class.external_parameters
    end

    # Use instance variables to build a json object. Instance
    # variables that begin with a single underscore are elided.
    # Instance variables that begin with two underscores have one of
    # them removed.
    def as_json(_options = {})
      hash = {}
      instance_variables.each do |var|
        name = var[1..-1]

        if name =~ /^__/
          # if a variable starts with double underscore, strip one off
          name = name[1..-1]
        elsif name =~ /^_/
          # Hide variables that start with single underscore
          name = nil
        end

        hash[name] = instance_variable_get(var) if name
      end
      hash
    end

    def to_json(*a)
      as_json.to_json(*a)
    end

    def ref_children
      instance_variables.map { |var| instance_variable_get(var) }
    end

    def declare(&block)
      instance_eval(&block) if block_given?
    end
  end

  # Handles all of the Fn:: objects
  class Fn < JSONable
    def initialize(function, argument, refs = [])
      @function = function
      @argument = argument
      @_refs = refs
    end

    def as_json(_options = {})
      hash = {}
      hash["Fn::#{@function}"] = @argument
      hash
    end

    def to_json(*a)
      as_json.to_json(*a)
    end

    def references
      @_refs
    end

    def ref_children
      [@argument]
    end
  end

  # Handles the Ref objects
  class RefDefinition < JSONable
    def initialize(value)
      @Ref = value
    end

    def all_refs
      [@Ref]
    end
  end
end
