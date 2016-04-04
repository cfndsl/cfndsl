require 'rake'
require 'rake/tasklib'

require 'cfndsl'

module CfnDsl
  # Rake Task
  class RakeTask < Rake::TaskLib
    attr_accessor :cfndsl_opts

    def initialize(name = nil)
      yield self if block_given?

      desc 'Generate Cloudformation' unless ::Rake.application.last_comment
      task(name || :generate) do |_t, _args|
        cfndsl_opts[:files].each do |opts|
          generate(opts)
        end
      end
    end

    private

    def generate(opts)
      log(opts)
      outputter(opts) do |output|
        output.puts model(opts[:filename])
      end
    end

    def log(opts)
      type = opts[:output].nil? ? 'STDOUT' : opts[:output]
      verbose.puts("Writing to #{type}") if verbose
    end

    def outputter(opts)
      opts[:output].nil? ? yield(STDOUT) : file_output(opts[:output]) { |f| yield f }
    end

    def model(filename)
      raise "#{filename} doesn't exist" unless File.exist?(filename)
      verbose.puts("using extras #{extra}") if verbose
      CfnDsl.eval_file_with_extras(filename, extra, verbose).to_json
    end

    def extra
      cfndsl_opts.fetch(:extras, [])
    end

    def verbose
      cfndsl_opts[:verbose] && STDERR
    end

    def file_output(path)
      File.open(File.expand_path(path), 'w') { |f| yield f }
    end
  end
end
