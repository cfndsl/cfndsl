require 'cfndsl/Errors'
require 'cfndsl/RefCheck'

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
        
    def FnBase64( value )
      ##
      # Equivalent to the CloudFormation template built in function Fn::Base64
      Fn.new("Base64", value);
    end
    
    def FnFindInMap( map, key, value)
      ##
      # Equivalent to the CloudFormation template built in function Fn::FindInMap
      Fn.new("FindInMap", [map,key,value] )
    end	
    
    def FnGetAtt(logicalResource, attribute)
      ##
      # Equivalent to the CloudFormation template built in function Fn::GetAtt
      Fn.new( "GetAtt", [logicalResource, attribute], [logicalResource] )
    end
    
    def FnGetAZs(region)
      ##
      # Equivalent to the CloudFormation template built in function Fn::GetAZs
      Fn.new("GetAZs", region)
    end
    
    def FnJoin(string, array)
      ##
      # Equivalent to the CloudFormation template built in function Fn::Join
      Fn.new("Join", [ string, array] )
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
      array = [];
      if(arguments.length == 0 ||
         (arguments.length == 1 && arguments[0].instance_of?(Hash)) ) then
        hash = arguments[0] || {}
        string.scan( /(.*?)(%(%|\{([\w:]+)\})|\z)/m ) do |x,y|
          array.push $1 if $1 && $1 != ""
          if( $3 == '%' ) then
            array.push '%'
          elsif( $3 ) then
            array.push hash[ $4 ] || hash[ $4.to_sym ] || Ref( $4 )
          end
        end  
      else
        string.scan( /(.*?)(%(%|\d+)|\z)/m ) do |x,y|
          array.push $1 if $1 && $1 != ""
          if( $3 == '%' ) then
            array.push '%'
          elsif( $3 ) then
            array.push arguments[ $3.to_i ]
          end
        end  
      end
      Fn.new("Join", ["", array])
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
      self.instance_variables.each do |var|
        name = var[1..-1]
        
        if( name =~ /^__/ ) then
          # if a variable starts with double underscore, strip one off
          name = name[1..-1]
        elsif( name =~ /^_/ ) then
          # Hide variables that start with single underscore
          name = nil
        end
          
        hash[name] = self.instance_variable_get var if name
      end
      hash.to_json(*a)
    end

    def ref_children
      return self.instance_variables.map { |var| self.instance_variable_get var }
    end

    def declare(&block)
      self.instance_eval &block if block_given?
    end

    def method_missing(meth,*args,&block) 
      if(args) then
        arg = "(" + args.inspect[1..-2] + ")"
      else 
        arg = ""
      end
      CfnDsl::Errors.error( "Undefined symbol: #{meth}#{arg}", 1 )
    end
  end

    
  class Fn < JSONable
    ##
    # Handles all of the Fn:: objects
    def initialize( function, argument, refs=[] )
      @function = function
      @argument = argument
      @_refs = refs
    end
    
    def to_json(*a)
      hash = {}
      hash["Fn::#{@function}"] = @argument
      hash.to_json(*a)
    end

    def get_references()
      return @_refs
    end

    def ref_children
      return [@argument]
    end
  end

  class RefDefinition < JSONable
    ##
    # Handles the Ref objects
    def initialize( value ) 
      @Ref = value
    end

    def get_references()
      [@Ref]
    end
  end
  
end
