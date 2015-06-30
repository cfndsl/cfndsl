require 'rake'
require 'rake/tasklib'
require 'cfndsl'

module CfnDsl
  class RakeTask < Rake::TaskLib
    attr_accessor :cfndsl_opts


    def initialize(name = nil)
      yield self if block_given?

      desc 'Generate Cloudformation' unless ::Rake.application.last_comment
      task(name || :generate) do |t, args|
        cfndsl_opts[:files].each do |opts|
          extra = cfndsl_opts[:extras] || []
          verbose = cfndsl_opts[:verbose] && STDERR
          model = CfnDsl::eval_file_with_extras(opts[:filename], extra, verbose)
          if opts[:output].nil?
            verbose.puts("Writing to STDOUT") if verbose
            STDOUT.puts model.to_json
          else
            verbose.puts("Writing to #{opts[:output]}") if verbose
            output = File.open( File.expand_path(opts[:output]), "w")
            output.puts model.to_json
          end
        end
      end
    end
  end
end
