require 'json';

class Module
  private
  def attr_setter(*symbols)
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
  
  def content_object(*symbols)
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
      Fn.new( "GetAtt", [logicalResource, attribute] )
    end
    
    def FnGetAZs(region)
      Fn.new("GetAZs", region)
    end
    
    def FnJoin(string, array)
      Fn.new("Join", [ string, array] )
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
        hash[name] = self.instance_variable_get var
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
    def initialize( function, argument )
      @function = function
      @argument = argument
    end
    
    def to_json(*a)
      hash = {}
      hash["Fn::#{@function}"] = @argument
      hash.to_json(*a)
    end

    def get_references( refs )
      refs[ @argument[0] ] = 1 if @function=="GetAtt"
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
    attr_setter :Type, :DependsOn, :DeletionPolicy
    content_object :Property, :Metadata

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
    attr_setter :Type, :Default, :NoEcho, :AllowedValues, :AllowedPattern, :MaxLength, :MinLength, :MaxValue, :MinValue, :Description, :ConstraintDescription
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
    attr_setter :Value, :Description
    
    def initialize( value=nil)
      @Value = value if value
    end
  end
  
  class CloudFormationTemplate < JSONable 
    attr_setter :AWSTemplateFormatVersion, :Description
    content_object :Parameter, :Output, :Resource, :Mapping
    
    def initialize
      @AWSTemplateFormatVersion = "2010-09-09"
    end
    
    def generateOutput() 
      puts self.to_json  # uncomment for pretty printing # {:space => ' ', :indent => '  ', :object_nl => "\n", :array_nl => "\n" }
    end
    
    def dsl(&block) 
      self.instance_eval &block
    end

  end
  
  
end

def CloudFormation(&block)
  x = CfnDsl::CloudFormationTemplate.new
  x.dsl(&block)
  x.generateOutput

end


