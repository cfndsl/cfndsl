# frozen_string_literal: true

require 'forwardable'
require 'json'

require 'deep_merge/deep_merge'
require 'cfndsl/globals'
require 'cfndsl/module'
require 'cfndsl/errors'
require 'cfndsl/ref_check'
require 'cfndsl/jsonable'
require 'cfndsl/properties'
require 'cfndsl/update_policy'
require 'cfndsl/creation_policy'
require 'cfndsl/conditions'
require 'cfndsl/mappings'
require 'cfndsl/resources'
require 'cfndsl/rules'
require 'cfndsl/parameters'
require 'cfndsl/outputs'
require 'cfndsl/specification'
require 'cfndsl/aws/cloud_formation_template'
require 'cfndsl/aws/cloud_formation'
require 'cfndsl/external_parameters'
require 'cfndsl/version'
require 'cfndsl/runner'

# CfnDsl
module CfnDsl
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
  # :raw  - the second element is treated as a ruby statement and is
  #         evaluated in the binding context, similar to the contents of
  #         a ruby file.
  #
  # Note that the order is important, as later extra sections can overwrite
  # or even undo things that were done by earlier sections.

  def self.eval_file_with_extras(filename, extras = [], logstream = nil)
    b = binding
    params = CfnDsl::ExternalParameters.refresh!
    extras.each do |type, file|
      case type
      when :yaml, :json
        klass_name = type.to_s.upcase
        logstream.puts("Loading #{klass_name} file #{file}") if logstream
        params.load_file file
      when :raw
        params.set_param(*file.split('='))
      end
    end

    logstream.puts("Loading template file #{filename}") if logstream
    b.eval(File.read(filename), filename)
  end
end

def CloudFormation(&block)
  x = CfnDsl::CloudFormationTemplate.new
  x.declare(&block)
  invalid_references = x.check_refs
  if invalid_references
    abort invalid_references.join("\n")
  elsif CfnDsl::Errors.errors?
    abort CfnDsl::Errors.errors.join("\n")
  else
    return x
  end
end
