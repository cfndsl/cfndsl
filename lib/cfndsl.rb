require 'json';

require 'cfndsl/module'
require 'cfndsl/RefCheck'
require 'cfndsl/JSONable'
require 'cfndsl/Types'

module CfnDsl
    
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

    def value
      return @value
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

    @@globalRefs = { 
       "AWS::NotificationARNs" => 1, 
       "AWS::Region" => 1,
       "AWS::StackId" => 1,
       "AWS::StackName" => 1
    }

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

    
    names = {}
    nametypes = {}
    CfnDsl::Types::AWS_Types["Resources"].each_pair do |name, type|
      # Subclass ResourceDefintion and generate property methods
      klass = Class.new(CfnDsl::ResourceDefinition)
      klassname = name.split("::").join("_")
      CfnDsl::Types.const_set( klassname, klass )
      type["Properties"].each_pair do |pname, ptype|
        if( ptype.instance_of? String )
          create_klass = CfnDsl::Types.const_get( ptype );
          klass.class_eval do 
            define_method(pname) do |*values, &block|
              if( values.length <1 ) then
                values.push create_klass.new 
              end
              @Properties ||= {}
              @Properties[pname] ||= CfnDsl::PropertyDefinition.new( *values )
              @Properties[pname].value.instance_eval &block if block
              @Properties[pname].value
            end
          end
        else
          #Array version
          sing_name = pname[0..-2]
          create_klass = CfnDsl::Types.const_get( ptype[0] );
          klass.class_eval do
            define_method(pname) do |*values, &block|
              if( values.length < 1 ) then
                values.push []
              end
              @Properties ||= {}
              @Properties[pname] ||= PropertyDefinition.new( *values )
              @Properties[pname].value.instance_eval &block if block
              @Properties[pname].value
            end

            define_method(sing_name) do |value=nil, &block|
              @Properties ||= {}
              @Properties[pname] ||= PropertyDefinition.new( [] )
              if( !value ) then
                value = create_klass.new
              end
              @Properties[pname].value.push value
              value.instance_eval &block if block
              value
            end

          end
        end

      end
      parts = name.split "::"
      while( parts.length > 0) 
        abreve_name = parts.join "_"
        if( names.has_key? abreve_name ) then
          # this only happens if there is an ambiguity
          names[abreve_name] = nil
        else
          names[abreve_name] = CfnDsl::Types.const_get(klassname)
          nametypes[abreve_name] = name
        end
        parts.shift
      end


    end
    
    #Define property setter methods for each of the unambiguous type names
    names.each_pair do |typename,type|
      if(type) then
        class_eval do
          define_method( typename) do |name,*values,&block|
            name = name.to_s
            @Resources ||= {}
            resource = @Resources[name] ||= type.new(*values)
            resource.instance_eval &block if block
            resource.instance_variable_set( "@Type", nametypes[typename] )
            resource
          end
        end
      end
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


