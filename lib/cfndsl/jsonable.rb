require 'cfndsl/errors'
require 'cfndsl/ref_check'

module CfnDsl
  module Functions
    ##
    # These functions are available anywhere inside
    # a block for a JSONable object.
    def Ref(value)
      ##
      # Equivalent to the CloudFormation template built in function Ref
      RefDefinition.new(value)
    end

    def FnBase64(value)
      ##
      # Equivalent to the CloudFormation template built in function Fn::Base64
      Fn.new('Base64', value)
    end

    def FnFindInMap(map, key, value)
      ##
      # Equivalent to the CloudFormation template built in function Fn::FindInMap
      Fn.new('FindInMap', [map, key, value])
    end

    def FnGetAtt(logical_resource, attribute)
      ##
      # Equivalent to the CloudFormation template built in function Fn::GetAtt
      Fn.new('GetAtt', [logical_resource, attribute])
    end

    def FnGetAZs(region)
      ##
      # Equivalent to the CloudFormation template built in function Fn::GetAZs
      Fn.new('GetAZs', region)
    end

    def FnJoin(string, array)
      ##
      # Equivalent to the CloudFormation template built in function Fn::Join
      Fn.new('Join', [string, array])
    end

    def FnAnd(array)
      ##
      # Equivalent to the CloudFormation template built in function Fn::And
      if !array || array.count < 2 || array.count > 10
        raise 'The array passed to Fn::And must have at least 2 elements and no more than 10'
      end
      Fn.new('And', array)
    end

    def FnEquals(value1, value2)
      ##
      # Equivalent to the Cloudformation template built in function Fn::Equals
      Fn.new('Equals', [value1, value2])
    end

    def FnIf(condition_name, true_value, false_value)
      ##
      # Equivalent to the Cloudformation template built in function Fn::If
      Fn.new('If', [condition_name, true_value, false_value])
    end

    def FnNot(value)
      ##
      # Equivalent to the Cloudformation template built in function Fn::Not
      Fn.new('Not', value)
    end

    def FnOr(array)
      ##
      # Equivalent to the CloudFormation template built in function Fn::Or
      if !array || array.count < 2 || array.count > 10
        raise 'The array passed to Fn::Or must have at least 2 elements and no more than 10'
      end
      Fn.new('Or', array)
    end

    def FnSelect(index, array)
      ##
      # Equivalent to the CloudFormation template built in function Fn::Select
      Fn.new('Select', [index, array])
    end

    def FnFormat(string, *arguments)
      ##
      # Usage
      #  FnFormat( "This is a %0. It is 100%% %1","test", "effective")
      # or
      #  FnFormat( "This is a %{test}. It is 100%% %{effective},
      #            :test=>"test",
      #            :effective=>"effective")
      #
      # These will each generate a call to Fn::Join that when
      # evaluated will produce the string "This is a test. It is 100%
      # effective."
      #
      # Think of this as %0,%1, etc in the format string being replaced by the
      # corresponding arguments given after the format string. '%%' is replaced
      # by the '%' character.
      #
      # The actual Fn::Join call corresponding to the above FnFormat call would be
      # {"Fn::Join": ["",["This is a ","test",". It is 100","%"," ","effective"]]}
      #
      # If no arguments are given, or if a hash is given and the format
      # variable name does not exist in the hash, it is used as a Ref
      # to an existing resource or parameter.
      #
      array = []
      if arguments.empty? || (arguments.length == 1 && arguments[0].instance_of?(Hash))
        hash = arguments[0] || {}
        string.scan(/(.*?)(%(%|\{([\w:]+)\})|\z)/m) do |w, _x, y, z|
          array.push w if w && w != ''
          if y == '%'
            array.push '%'
          elsif y
            array.push hash[z] || hash[z.to_sym] || Ref(z)
          end
        end
      else
        string.scan(/(.*?)(%(%|\d+)|\z)/m) do |x, _y, z|
          array.push x if x && x != ''
          if z == '%'
            array.push '%'
          elsif z
            array.push arguments[z.to_i]
          end
        end
      end
      Fn.new('Join', ['', array])
    end
  end

  class JSONable
    ##
    # This is the base class for just about everything useful in the
    # DSL. It knows how to turn DSL Objects into the corresponding
    # json, and it lets you create new built in function objects
    # from inside the context of a dsl object.

    include Functions
    extend Functions
    include RefCheck

    def to_json(*a)
      ##
      # Use instance variables to build a json object. Instance
      # variables that begin with a single underscore are elided.
      # Instance variables that begin with two underscores have one of
      # them removed.
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
      hash.to_json(*a)
    end

    def ref_children
      instance_variables.map { |var| instance_variable_get(var) }
    end

    def declare(&block)
      instance_eval(&block) if block_given?
    end

    def method_missing(meth, *args, &_block)
      error = "Undefined symbol: #{meth}"
      error = "#{error}(" + args.inspect[1..-2] + ')' unless args.empty?
      error = "#{error}\n\nTry '#{titleize(meth)}' instead" if incorrect_capitalization?(meth)
      CfnDsl::Errors.error(error, 1)
    end

    def incorrect_capitalization?(method)
      method != titleize(method) && respond_to?(titleize(method))
    end

    def titleize(method)
      method.to_s.clone.tap do |m|
        m[0] = m[0, 1].upcase
      end.to_sym
    end
  end

  class Fn < JSONable
    ##
    # Handles all of the Fn:: objects
    def initialize(function, argument, refs = [])
      @function = function
      @argument = argument
      @_refs = refs
    end

    def to_json(*a)
      hash = {}
      hash["Fn::#{@function}"] = @argument
      hash.to_json(*a)
    end

    def references
      @_refs
    end

    def ref_children
      [@argument]
    end
  end

  class RefDefinition < JSONable
    ##
    # Handles the Ref objects
    def initialize(value)
      @Ref = value
    end

    def get_references
      [@Ref]
    end
  end
end
