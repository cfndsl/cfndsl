require 'yaml'
require 'cfndsl/JSONable'
module CfnDsl
  module Types

    aws_types = YAML::load( File.open( "#{File.dirname(__FILE__)}/aws_types.yaml") );
    Types.const_set( "AWS_Types", aws_types);
    
    # Do a little sanity checking - all of the types referenced in Resources
    # should be represented in Types
    aws_types["Resources"].keys.each do |resource_name|
      #puts resource_name
      resource = aws_types["Resources"][resource_name]
      resource.values.each do |thing|
        thing.values.each do |type|
          if( type.kind_of? Array ) then
            type.each do | type |
              puts "unknown type #{type}" unless aws_types["Types"].has_key? type 
            end
          else
            puts "unknown type #{type}" unless aws_types["Types"].has_key? type 
          end
        end
      end
    end
    
    # All of the type values should also be references
    
    aws_types["Types"].values do |type|
      if( type.respond_to? :values) then
        type.values.each do |tv|
          puts "unknown type #{tv}" unless aws_types["Types"].has_key? tv 
        end
      end
    end
    
    
  
    # declare classes for all of the types with named methods for setting the values
    class AWSType < JSONable
    end
  
    classes = {}
    
    # Go through and declare all of the types first
    aws_types["Types"].each_key do |typename|
      if( ! Types.const_defined? typename ) then
        klass = Types.const_set( typename, Class.new(AWSType ) )
        classes[typename] = klass
      else
        classes[typename] = Types.const_get(typename)
      end 
    end
    
    # Now go through them again and define attribute setter methods
    classes.each_pair do |typename,type|
      #puts typename
      typeval = aws_types["Types"][typename]
      if( typeval.respond_to? :each_pair ) then
        typeval.each_pair do |attr_name, attr_type|
          if( attr_type.kind_of? Array ) then
            klass = Array
          else
            klass = CfnDsl::Types.const_get( attr_type );
          end
          variable = "@#{attr_name}".to_sym

          type.class_eval do | value=nil, *rest, &block |
            value ||= klass.new
            instance_variable_set( variable, value )
            value.instance_eval &block if block
            value
          end
        end
      end
    end
  end  
end

