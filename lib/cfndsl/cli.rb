require 'cfndsl'
require 'optparse'

module CfnDsl
  class Cli
    def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
      @argv = argv
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
      @kernel = kernel
    end

    def execute!
      options = {}

      optparse = OptionParser.new do|opts|
        opts.banner = "Usage: cfndsl [options] FILE"

        # Define the options, and what they do
        options[:output] = '-'
        opts.on( '-o', '--output FILE', 'Write output to file' ) do |file|
          options[:output] = file
        end

        options[:extras] = []
        opts.on( '-y', '--yaml FILE', 'Import yaml file as local variables' ) do |file|
          options[:extras].push([:yaml,File.expand_path(file)])
        end

        opts.on( '-r', '--ruby FILE', 'Evaluate ruby file before template' ) do |file|
          options[:extras].push([:ruby,File.expand_path(file)])
        end

        opts.on( '-j', '--json FILE', 'Import json file as local variables' ) do |file|
          options[:extras].push([:json,File.expand_path(file)])
        end

        opts.on( '-D', '--define "VARIABLE=VALUE"', 'Directly set local VARIABLE as VALUE' ) do |file|
          options[:extras].push([:raw,file])
        end

        options[:verbose] = false
        opts.on('-v', '--verbose', "Turn on verbose ouptut") do
          options[:verbose] = true
        end

        # This displays the help screen, all programs are
        # assumed to have this option.
        opts.on( '-h', '--help', 'Display this screen' ) do
          puts opts
          exit
        end
      end

      optparse.parse!
      unless @argv[0] then
        puts optparse.help
        exit(1)
      end



      filename = File.expand_path(@argv[0]) || options[:file]
      verbose = options[:verbose] && STDERR

      model = CfnDsl::eval_file_with_extras(filename, options[:extras], verbose)

      output = STDOUT
      if options[:output] != '-' then
        verbose.puts("Writing to #{options[:output]}") if verbose
        output = File.open( File.expand_path(options[:output]), "w")
      else
        verbose.puts("Writing to STDOUT") if verbose
      end

      output.puts model.to_json
    end
  end
end
