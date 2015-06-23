require 'rake'
require 'rake/tasklib'
require 'cfndsl/cli'

module CfnDsl
  class RakeTask < Rake::TaskLib
    attr_accessor :opts

    def initialize(name = nil)
      yield self if block_given?

      desc 'Generate Cloudformation' unless ::Rake.application.last_comment
      task(name || :generate) do |t, args|
        Cli.new(opts || []).execute!
      end
    end
  end
end
