# frozen_string_literal: true

require 'optparse'
require 'json'
require_relative 'globals'
# Defer require of other capabilities (particularly loading dynamic Types) until required

module CfnDsl
  # Runner class to handle commandline invocation
  class Runner
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    def self.invoke!
      options = {}

      optparse = OptionParser.new do |opts|
        opts.version = CfnDsl::VERSION
        opts.banner = 'Usage: cfndsl [options] FILE'

        # Define the options, and what they do
        options[:output] = '-'
        opts.on('-o', '--output FILE', 'Write output to file') do |file|
          options[:output] = file
        end

        options[:extras] = []
        opts.on('-y', '--yaml FILE', 'Import yaml file as local variables') do |file|
          options[:extras].push([:yaml, File.expand_path(file)])
        end

        opts.on('-j', '--json FILE', 'Import json file as local variables') do |file|
          options[:extras].push([:json, File.expand_path(file)])
        end

        opts.on('-p', '--pretty', 'Pretty-format output JSON') do
          options[:pretty] = true
        end

        opts.on('-f', '--format FORMAT', 'Specify the output format (JSON default)') do |format|
          raise "Format #{format} not supported" unless %w[json yaml].include? format

          options[:outformat] = format
        end

        opts.on('-D', '--define "VARIABLE=VALUE"', 'Directly set local VARIABLE as VALUE') do |file|
          options[:extras].push([:raw, file])
        end

        options[:verbose] = false
        opts.on('-v', '--verbose', 'Turn on verbose ouptut') do
          options[:verbose] = true
        end

        opts.on('-m', '--disable-deep-merge', 'Disable deep merging of yaml') do
          CfnDsl.disable_deep_merge
        end

        # TODO: Support options to add a spec/patches dir
        opts.on('-s', '--specification-file FILE', 'Location of Cloudformation Resource Specification file') do |file|
          CfnDsl.specification_file File.expand_path(file)
        end

        opts.on('-u', '--update-specification [VERSION]', 'Update the Resource Specification file to latest, or specific version') do |file|
          options[:spec_version] = file || 'latest'
          options[:update_spec] = true
        end

        opts.on('-g', '--generate RESOURCE_TYPE,RESOURCE_LOGICAL_NAME', 'Add resource type and logical name') do |r|
          options[:lego] = true
          options[:resources] = []
          options[:resources] << r
        end

        opts.on('-a', '--assetversion', 'Print out the specification version') do
          options[:assetversion] = true
        end

        opts.on('-l', '--list', 'List supported resources') do
          require_relative 'cfnlego'
          puts Cfnlego.Resources.sort
          exit
        end

        # This displays the help screen, all programs are
        # assumed to have this option.
        opts.on('-h', '--help', 'Display this screen') do
          puts opts
          exit
        end
      end

      optparse.parse!

      if options[:update_spec]
        warn 'Updating specification file'
        result = CfnDsl.update_specification_file(version: options[:spec_version])
        warn "Specification #{result[:version]} successfully written to #{result[:file]}"
      end

      if options[:assetversion]
        spec_file = JSON.parse File.read(CfnDsl.specification_file)
        warn spec_file['ResourceSpecificationVersion']
      end

      if options[:lego]
        require_relative 'cfnlego'
        puts Cfnlego.run(options)
        exit
      end

      if ARGV.empty?
        if options[:update_spec] || options[:assetversion]
          exit 0
        else
          puts optparse.help
          exit 1
        end
      end

      filename = File.expand_path(ARGV[0])
      verbose = options[:verbose] && $stderr

      verbose.puts "Using specification file #{CfnDsl.specification_file}" if verbose

      require_relative 'cloudformation'
      model = CfnDsl.eval_file_with_extras(filename, options[:extras], verbose)

      output = $stdout
      if options[:output] != '-'
        verbose.puts("Writing to #{options[:output]}") if verbose
        output = File.open(File.expand_path(options[:output]), 'w')
      elsif verbose
        verbose.puts('Writing to STDOUT')
      end

      if options[:outformat] == 'yaml'
        data = model.to_json
        output.puts JSON.parse(data).to_yaml
      else
        output.puts options[:pretty] ? JSON.pretty_generate(model) : model.to_json
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
end
