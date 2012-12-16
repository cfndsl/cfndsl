require 'json';

class Module
  private
  def dsl_attr_setter(*symbols)
    ##
    # Create setter methods
    #
    # Usage:
    #    class Something
    #      dsl_attr_setter :Thing
    #    end
    #
    # Generates a setter method like this one for each symbol in *symbols:
    #
    # def Thing(value)
    #   @Thing = value
    # end
    #
    symbols.each do |symbol|
      class_eval do 
        define_method(symbol) do |value|
          instance_variable_set( "@#{symbol}", value)
        end
      end	
    end
  end
  
  ##
  # Plural names for lists of content objects
  #
  
  @@plurals = { 
    :Metadata => :Metadata, 
    :Property => :Properties 
  }
  
  def dsl_content_object(*symbols)
    ##
    # Create object declaration methods.
    #
    # Usage:
    #   Class Something
    #     dsl_content_object :Stuff
    #   end
    #
    # Generates methods like this:
    #
    # def Stuff(name, *values, &block) 
    #   @Stuffs ||= {}
    #   @Stuffs[name] ||= CfnDsl::#{symbol}Definition.new(*values)
    #   @Stuffs[name].instance_eval &block if block_given?
    #   return @Stuffs[name]
    # end
    #
    # The effect of this is that you can then create named sub-objects
    # from the main object. The sub objects get stuffed into a container
    # on the main object, and the block is then evaluated in the context
    # of the new object.
    #
    symbols.each do |symbol|
      plural = @@plurals[symbol] || "#{symbol}s"
      class_eval %Q/
        def #{symbol} (name,*values,&block)
          name = name.to_s
          @#{plural} ||= {}
          @#{plural}[name] ||= CfnDsl::#{symbol}Definition.new(*values)
          @#{plural}[name].instance_eval &block if block_given? 
          return @#{plural}[name]
        end /
    end
  end
end


module RefCheck
  ##
  # This module defines some methods for walking the reference tree
  # of various objects.
  #
  def references(refs)
    ##
    # Build up a set of references.
    #
    raise "Circular reference" if @_visited

    @_visited = true
    
    if( self.respond_to?(:get_references ) ) then
      self.get_references.each do |ref|
        refs[ref.to_s] = 1
      end
    end

    self.ref_children.each do |elem|
      elem.references(refs) if elem.respond_to?(:references)
    end

    @_visited = nil

    return refs
  end

  def ref_children
    return []
  end

end

class Array
  include RefCheck
  def ref_children
    return self
  end
end

class Hash
  include RefCheck
  def ref_children
    return self.values
  end
end      

module CfnDsl
  module Functions  

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
      # 
      # This will generate a call to Fn::Join that when evaluated will produce
      # the string "This is a test. It is 100% effective."
      #
      # Think of this as %0,%1, etc in the format string being replaced by the 
      # corresponding arguments given after the format string. '%%' is replaced
      # by the '%' character. 
      # 
      # The actual Fn::Join call corresponding to the above FnFormat call would be
      # {"Fn::Join": ["",["This is a ","test",". It is 100","%"," ","effective"]]}
      array = [];
      string.scan( /(.*?)(%(%|\d+)|\z)/m ) do |x,y|
        array.push $1 if $1 && $1 != ""
        if( $3 == '%' ) then
          array.push '%'
        elsif( $3 ) then
          array.push arguments[ $3.to_i ]
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
  
  
  class PropertyDefinition < JSONable
    ##
    # Handles property objects for Resources
    #
    # Usage
    #   Resource("aaa") {
    #     Property("propName", "propValue" )
    #   }
    #
    def initialize(value) 
      @value = value;
    end
    
    def to_json(*a) 
      @value.to_json(*a)
    end
  end
  
  class MappingDefinition < JSONable
    ##
    # Handles mapping objects
    #
    # Usage:
    #     Mapping("AWSRegionArch2AMI", {
    #               "us-east-1" => { "32" => "ami-6411e20d", "64" => "ami-7a11e213" },
    #               "us-west-1" => { "32" => "ami-c9c7978c", "64" => "ami-cfc7978a" },
    #               "eu-west-1" => { "32" => "ami-37c2f643", "64" => "ami-31c2f645" },
    #               "ap-southeast-1" => { "32" => "ami-66f28c34", "64" => "ami-60f28c32" },
    #               "ap-northeast-1" => { "32" => "ami-9c03a89d", "64" => "ami-a003a8a1" }
    #    })
    
    def initialize(value)
      @value = value
    end
    
    def to_json(*a)
      @value.to_json(*a)
    end
  end
  
  class ResourceDefinition < JSONable
    ##
    # Handles Resource objects
    dsl_attr_setter :Type, :DependsOn, :DeletionPolicy
    dsl_content_object :Property, :Metadata

    def get_references()
      refs = []
      if @DependsOn then
        if( @DependsOn.respond_to?(:each) ) then
          @DependsOn.each do |dep|
            refs.push dep
          end
        end

        if( @DependsOn.instance_of?(String) ) then
          refs.push @DependsOn 
        end
      end

      refs
    end
  end
  
  class MetadataDefinition < JSONable
    ## 
    # Handles Metadata objects
  end
  
  
  class ParameterDefinition < JSONable
    ##
    # Handles input parameter objects
    dsl_attr_setter :Type, :Default, :NoEcho, :AllowedValues, :AllowedPattern, :MaxLength, :MinLength, :MaxValue, :MinValue, :Description, :ConstraintDescription
    def initialize
      @Type = :String
    end
    
    def String
      @Type = :String
    end
    
    def Number
      @Type = :Number
    end
    
    def CommaDelimitedList
      @Type = :CommaDelimitedList
    end
    
    def to_hash()
      h = {}
      h[:Type] = @Type;
      h[:Default] = @Default if @Default
    end
  end
  
  class OutputDefinition < JSONable
    ##
    # Handles Output objects
    dsl_attr_setter :Value, :Description
    
    def initialize( value=nil)
      @Value = value if value
    end
  end
  
  class CloudFormationTemplate < JSONable 
    ##
    # Handles the overall template object
    dsl_attr_setter :AWSTemplateFormatVersion, :Description
    dsl_content_object :Parameter, :Output, :Resource, :Mapping
    
    def initialize
      @AWSTemplateFormatVersion = "2010-09-09"
    end
    
    def generateOutput() 
      puts self.to_json  # uncomment for pretty printing # {:space => ' ', :indent => '  ', :object_nl => "\n", :array_nl => "\n" }
    end

    @@globalRefs = { "AWS::Region" => 1 }

    def isValidRef( ref, origin=nil)
      ref = ref.to_s
      origin = origin.to_s if origin

      return true if @@globalRefs.has_key?( ref )

      return true if @Parameters && @Parameters.has_key?( ref )
      
      if( @Resources.has_key?( ref ) ) then
          return !origin || !@_ResourceRefs || !@_ResourceRefs[ref] || !@_ResourceRefs[ref].has_key?(origin)             
      end

      return false
    end

    def checkRefs() 
      invalids = []
      @_ResourceRefs = {}
      if(@Resources)  then
        @Resources.keys.each do |resource|
          @_ResourceRefs[resource.to_s] = @Resources[resource].references({})
        end
        @_ResourceRefs.keys.each do |origin|
          @_ResourceRefs[origin].keys.each do |ref|
            invalids.push "Invalid Reference: Resource #{origin} refers to #{ref}" unless isValidRef(ref,origin)
          end
        end
      end
      outputRefs = {}
      if(@Outputs) then
        @Outputs.keys.each do |resource|
          outputRefs[resource.to_s] = @Outputs[resource].references({})
        end
        outputRefs.keys.each do |origin|
          outputRefs[origin].keys.each do |ref|
            invalids.push "Invalid Reference: Output #{origin} refers to #{ref}" unless isValidRef(ref,nil)
          end
        end
      end
      return invalids.length>0 ? invalids : nil 
    end

  end
end

def CloudFormation(&block)
  x = CfnDsl::CloudFormationTemplate.new
  x.declare(&block)
  invalid_references = x.checkRefs()
  if( invalid_references ) then
    puts invalid_references.join("\n");
    exit(-1)
  else
    x.generateOutput
  end
end


