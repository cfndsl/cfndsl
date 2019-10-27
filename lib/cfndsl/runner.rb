# frozen_string_literal: true

require 'optparse'
require 'open-uri'

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

        opts.on('-s', '--specification-file FILE', 'Location of Cloudformation Resource Specification file') do |file|
          CfnDsl.specification_file File.expand_path(file)
        end

        opts.on('-u', '--update-specification', 'Update the Cloudformation Resource Specification file') do
          options[:update_spec] = true
        end

        opts.on('-g', '--generate RESOURCE_TYPE,RESOURCE_LOGICAL_NAME', 'Add resource type and logical name') do |r|
          options[:lego] = true
          options[:resources] << r
        end

        opts.on('-a', '--assetversion', 'Print out the specification version') do
          options[:assetversion] = true
        end

        opts.on('-l', '--list', 'List supported resources') do
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
        STDERR.puts 'Updating specification file'
        FileUtils.mkdir_p File.dirname(CfnDsl.specification_file)
        content = open('https://d1uauaxba7bl26.cloudfront.net/latest/CloudFormationResourceSpecification.json').read
        File.open(CfnDsl.specification_file, 'w') { |f| f.puts content }
        STDERR.puts "Specification successfully written to #{CfnDsl.specification_file}"
      end

      if options[:assetversion]
        spec_file = JSON.parse File.read(CfnDsl.specification_file)
        STDERR.puts spec_file['ResourceSpecificationVersion']
      end

      if options[:lego]
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
      verbose = options[:verbose] && STDERR

      verbose.puts "Using specification file #{CfnDsl.specification_file}" if verbose

      model = CfnDsl.eval_file_with_extras(filename, options[:extras], verbose)

      output = STDOUT
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
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
