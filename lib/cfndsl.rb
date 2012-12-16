require 'json';

class Module
  private
  def dsl_attr_setter(*symbols)
    symbols.each do |symbol|
      class_eval do 
        define_method(symbol) do |value|
          instance_variable_set( "@#{symbol}", value)
        end
      end	
    end
  end
  
  @@plurals = { 
    :Metadata => :Metadata, 
    :Property => :Properties 
  }
  
  def dsl_content_object(*symbols)
    symbols.each do |symbol|
      plural = @@plurals[symbol] || "#{symbol}s"
      class_eval %Q/
        def #{symbol} (name,*values,&block)
          @#{plural} ||= {}
          @#{plural}[name] ||= CfnDsl::#{symbol}Definition.new(*values)
          @#{plural}[name].instance_eval &block if block_given? 
          return @#{plural}[name]
        end /
    end
  end
end


module RefCheck
  def references(refs)
    raise "Circular reference" if @visited

    @visited = true

    self.get_references(refs) if self.respond_to?(:get_references)

    self.ref_children.each do |elem|
      elem.references(refs) if elem.respond_to?(:references)
    end
    @visited = nil
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
      RefDefinition.new(value)
    end
        
    def FnBase64( value )
      Fn.new("Base64", value);
    end
    
    def FnFindInMap( map, key, value)
      Fn.new("FindInMap", [map,key,value] )
    end	
    
    def FnGetAtt(logicalResource, attribute)
      Fn.new( "GetAtt", [logicalResource, attribute], [logicalResource] )
    end
    
    def FnGetAZs(region)
      Fn.new("GetAZs", region)
    end
    
    def FnJoin(string, array)
      Fn.new("Join", [ string, array] )
    end

    def FnFormat(string, *arguments)
      array = [];
      string.scan( /(.*?)(%(%|\d+)|$)/ ) do |x,y|
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
    include Functions
    extend Functions
    include RefCheck

    def to_json(*a)
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

    def get_references( refs )
      return @_refs
    end

    def ref_children
      return [@argument]
    end


  end


  class RefDefinition < JSONable
    def initialize( value ) 
      @Ref = value
    end

    def get_references( refs )
      refs[ @Ref ] = 1
    end
  end
  
  
  class PropertyDefinition < JSONable
    def initialize(value) 
      @value = value;
    end
    
    def to_json(*a) 
      @value.to_json(*a)
    end
  end
  
  class MappingDefinition < JSONable
    def initialize(value)
      @value = value
    end
    
    def to_json(*a)
      @value.to_json(*a)
    end
  end
  
  class ResourceDefinition < JSONable
    dsl_attr_setter :Type, :DependsOn, :DeletionPolicy
    dsl_content_object :Property, :Metadata

    def get_references( refs )
      if @DependsOn then
        if( @DependsOn.respond_to?(:each) ) then
          @DependsOn.each do |dep|
            refs[ dep ] = 1
          end
        end

        if( @DependsOn.instance_of?(String) ) then
          refs[ @DependsOn ] = 1
        end
      end
    end
  end
  
  class MetadataDefinition < JSONable
  end
  
  
  class ParameterDefinition < JSONable
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
    dsl_attr_setter :Value, :Description
    
    def initialize( value=nil)
      @Value = value if value
    end
  end
  
  class CloudFormationTemplate < JSONable 
    dsl_attr_setter :AWSTemplateFormatVersion, :Description
    dsl_content_object :Parameter, :Output, :Resource, :Mapping
    
    def initialize
      @AWSTemplateFormatVersion = "2010-09-09"
    end
    
    def generateOutput() 
      puts self.to_json  # uncomment for pretty printing # {:space => ' ', :indent => '  ', :object_nl => "\n", :array_nl => "\n" }
    end
    

  end
  
  
end

def CloudFormation(&block)
  x = CfnDsl::CloudFormationTemplate.new
  x.declare(&block)
  x.generateOutput
end


