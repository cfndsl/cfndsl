require 'yaml'

aws_types = YAML::load( File.open( 'aws_types.yaml') );

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

module Types

class AWSType 
end
  
classes = {}

# Go through and declare all of the types first
aws_types["Types"].keys do |typename|
  klass = self.const_set( typename, Class.new(AWSType ) )
  classes[typename] = klass
end

# Now go through them again and define attribute setter methods
classes.each_pair do |typename,type|
  aws_types["Types"][typename].each_pair do |attr_name, attr_type|
    puts attr_name, attr_type
    class_eval(type) %Q!
      def #{symbol} (value=nil,*rest,&block)
        if value then
          @#{attr_name} = #{attr_type}.new
        else
          @#{attr_name} = value
        end
        
        @#{attr_name}.instance_eval &block if block_given?
      end !
  end
end
    
