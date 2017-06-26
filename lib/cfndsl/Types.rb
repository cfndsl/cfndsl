require 'yaml'
require 'cfndsl/JSONable'
require 'cfndsl/Plurals'
require 'cfndsl/names'

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
            klass = CfnDsl::Types.const_get( attr_type[0] )
            variable = "@#{attr_name}".to_sym
            
            method = CfnDsl::Plurals::singularize(attr_name)
            methods = attr_name
            all_methods = CfnDsl::methodNames(method) +
              CfnDsl::methodNames(methods)
            type.class_eval do
              all_methods.each do |method_name|
                define_method(method_name) do | value=nil, *rest, &block|
                  existing = instance_variable_get( variable )                  
                  # For no-op invocations, get out now
                  return existing if value.nil? and rest.length == 0 and ! block
                  
                  # We are going to modify the value in some
                  # way, make sure that we have an array to mess
                  # with if we start with nothing
                  if( !existing ) then
                    existing = instance_variable_set( variable, [] )
                  end

                  # special case for just a block, no args
                  if( value.nil? and rest.length == 0 and block ) then
                    val = klass.new
                    existing.push val
                    value.instance_eval &block(val)
                    return existin
                  end
                     
                  # Glue all of our parameters together into
                  # a giant array - flattening one level deep, if needed
                  array_params = []
                  if( value.kind_of? Array) then 
                    value.each {|x| array_params.push x}
                  else
                    array_params.push value
                  end
                  if( rest.length > 0) then
                    rest.each do |v|
                      if( v.kind_of? Array ) then
                        array_params += rest
                      else
                        array_params.push v
                      end
                    end
                  end
                  
                  # Here, if we were given multiple arguments either
                  # as method [a,b,c], method(a,b,c), or even 
                  # method( a, [b], c) we end up with 
                  # array_params = [a,b,c]
                  #
                  # array_params will have at least one item
                  # unless the user did something like pass in
                  # a bunch of empty arrays.
                  if block then
                    array_params.each do |val|
                      value = klass.new
                      existing.push value
                      value.instance_eval &block(val) if block
                    end
                  else
                    # List of parameters with no block -
                    # hope that the user knows what he is
                    # doing and stuff them into our existing 
                    # array
                    array_params.each do |val|
                      existing.push value
                    end
                  end
                  return existing
                end
              end
            end
          else
            klass = CfnDsl::Types.const_get( attr_type );
            variable = "@#{attr_name}".to_sym

            type.class_eval do 
              CfnDsl::methodNames(attr_name) do |method|
                define_method(method) do | value=nil, *rest, &block |
                  value = klass.new if value.nil?
                  instance_variable_set( variable, value )
                  value.instance_eval &block if block
                  value
                end
              end
            end  
          end
        end
      end
    end
  end  
end

