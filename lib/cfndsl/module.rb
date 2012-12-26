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
