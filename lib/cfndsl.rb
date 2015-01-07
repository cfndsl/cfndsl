require 'json';

require 'cfndsl/module'
require 'cfndsl/Errors'
require 'cfndsl/RefCheck'
require 'cfndsl/JSONable'
require 'cfndsl/Types'
require 'cfndsl/Properties'
require 'cfndsl/UpdatePolicy'
require 'cfndsl/CreationPolicy'
require 'cfndsl/Conditions'
require 'cfndsl/Mappings'
require 'cfndsl/Resources'
require 'cfndsl/Metadata'
require 'cfndsl/Parameters'
require 'cfndsl/Outputs'
require 'cfndsl/CloudFormationTemplate'

module CfnDsl
  def self.eval_file_with_extras(filename, extras = [], logstream = nil)
    # This function handles the eval of the template file and returns the
    # results. It does this with a ruby "eval", but it builds up a customized
    # binding environment before it calls eval. The environment can be
    # customized by passing a list of customizations in the extras parameter.
    #
    # These customizations are expressed as an array of pairs of
    # (type,filename). They are evaluated in the order they appear in the
    # extras array. The types are as follows
    #
    # :yaml - the second element is treated as a file name, which is loaded
    #         as a yaml file. The yaml file should contain a top level
    #         dictionary. Each of the keys of the top level dictionary is
    #         used as a local variable in the evalation context.
    #
    # :json - the second element is treated as a file name, which is loaded
    #         as a json file. The yaml file should contain a top level
    #         dictionary. Each of the keys of the top level dictionary is
    #         used as a local variable in the evalation context.
    #
    # :ruby - the second element is treated as a file name which is evaluated
    #         as a ruby file. Any assigments (or other binding affecting
    #         side effects) will persist into the context where the template
    #         is evaluated
    #
    # :raw  - the seccond elements is treated as a ruby statement and is
    #         evaluated in the binding context, similar to the contents of
    #         a ruby file.
    #
    # Note that the order is important, as later extra sections can overwrite
    # or even undo things that were done by earlier sections.

    b = binding
    extras.each do |pair|
      type,file = pair
      case type
      when :yaml
        logstream.puts("Loading YAML file #{file}") if logstream
        parameters = YAML.load(File.read(file))
        parameters.each do |k,v|
          logstream.puts("Setting local variable #{k} to #{v}") if logstream
          b.eval("#{k} = #{v.inspect}")
        end

      when :json
        logstream.puts("Loading YAML file #{file}") if logstream
        parameters = JSON.load(File.read(file))
        parameters.each do |k,v|
          logstream.puts("Setting local variable #{k} to #{v}") if logstream
          b.eval("#{k} = #{v.inspect}")
        end

      when :ruby
        logstream.puts("Runnning ruby file #{file}") if logstream
        b.eval(File.read(file), file)

      when :raw
        logstream.puts("Running raw ruby code #{file}") if logstream
        b.eval(file, "raw code")
      end
    end

    logstream.puts("Loading template file #{filename}") if logstream
    model = b.eval(File.read(filename), filename)
    return model
  end
end

def CloudFormation(&block)
  x = CfnDsl::CloudFormationTemplate.new
  x.declare(&block)
  invalid_references = x.checkRefs()
  if( invalid_references ) then
    abort invalid_references.join("\n")
  elsif( CfnDsl::Errors.errors? ) then
    abort CfnDsl::Errors.errors.join("\n")
  else
    return x
  end
end

def Heat(&block)
  x = CfnDsl::HeatTemplate.new
  x.declare(&block)
  invalid_references = x.checkRefs()
  if( invalid_references ) then
    abort invalid_references.join("\n")
  elsif( CfnDsl::Errors.errors? ) then
    abort CfnDsl::Errors.errors.join("\n")
  else
    return x
  end
end

