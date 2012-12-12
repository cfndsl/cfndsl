require 'json';

def attr_setter(*symbols)
	symbols.each do |symbol|
		class_eval( "def #{symbol}(value) @#{symbol} = value; end")
	end	
end

@@plurals = { :Metadata => :Metadata, 
  	          :Property => :Properties }

def content_object(*symbols)
	symbols.each do |symbol|
		plural = @@plurals[symbol] || "#{symbol}s"
		class_eval( "def #{symbol}(name, *values, &block) @#{plural} ||= {}; @#{plural}[name] ||= #{symbol}Definition.new(*values); @#{plural}[name].instance_eval &block if block_given?;  end")
	end
end


class JSONable
  def to_json(*a)
    hash = {}
    self.instance_variables.each do |var|
	  name = var[1..-1]
      hash[name] = self.instance_variable_get var
    end
    hash.to_json(*a)
  end
end

class RefDefinition < JSONable
  def initialize( value ) 
    @Ref = value
  end
end

def Ref(value) 
  RefDefinition.new(value)
end

class Fn
	def initialize( function, argument )
		@function = function
		@argument = argument
	end
	
	def to_json(*a)
		hash = {}
		hash["Fn::#{@function}"] = @argument
		hash.to_json(*a)
	end
end

def FnBase64( value )
	Fn.new("Base64", value);
end

def FnFindInMap( map, key, value)
	Fn.new("FindInMap", [map,key,value])
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

class PropertyDefinition
	def initialize(value) 
		@value = value;
	end
	
	def to_json(*a) 
		@value.to_json(*a)
	end
end

class MappingDefintion
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
    puts self.to_json
  end

  def dsl(&block) 
    self.instance_eval &block
  end

end

def CloudFormation(&block)
  x = CloudFormationTemplate.new
  x.dsl(&block)
  x.generateOutput
end


