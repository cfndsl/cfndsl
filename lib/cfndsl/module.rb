require 'cfndsl/plurals'
require 'cfndsl/names'

class Module
  private

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
  def dsl_attr_setter(*symbols)
    symbols.each do |symbol|
      class_eval do
        CfnDsl.method_names(symbol) do |method|
          define_method(method) do |value|
            instance_variable_set("@#{symbol}", value)
          end
        end
      end
    end
  end

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
  def dsl_content_object(*symbols)
    symbols.each do |symbol|
      plural = CfnDsl::Plurals.pluralize(symbol) # @@plurals[symbol] || "#{symbol}s"
      pluralvar = "@#{plural}".to_sym
      definition_class = CfnDsl.const_get("#{symbol}Definition")
      class_eval do
        CfnDsl.method_names(symbol) do |method|
          define_method(method) do |name, *values, &block|
            name = name.to_s
            hash = instance_variable_get(pluralvar)
            unless hash
              hash = {}
              instance_variable_set(pluralvar, hash)
            end
            hash[name] ||= definition_class.new(*values)
            hash[name].instance_eval(&block) if block
            return hash[name]
          end
        end
      end
    end
  end
end
