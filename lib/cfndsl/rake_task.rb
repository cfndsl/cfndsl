# frozen_string_literal: true

require 'rake/tasklib'
require_relative 'globals'
require_relative 'specification'

# Monkey patch Rake
module Rake
  # Default verbosity to false
  def self.verbose?
    verbose && verbose != FileUtilsExt::DEFAULT
  end
end

module CfnDsl
  # Rake TaskLib
  # rubocop:disable Metrics/ClassLength
  class RakeTask < Rake::TaskLib
    # @deprecated pre 1.x rake task generator
    attr_accessor :cfndsl_opts

    # Creates Cloudformation generation tasks
    #
    # @example
    # directory 'tmp'
    #
    # namespace :samples do
    #
    #   CfnDsl::RakeTask.new do |t|
    #     t.specification(file: 'tmp/cloudformation_resources.json')
    #
    #     desc 'Generate CloudFormation Json'
    #     t.json(name: :json, files: ["sample/*.rb"], pathmap: 'tmp/%f.json', pretty: true, extras: FileList.new('sample/*.yaml') )
    #
    #     t.yaml(name: :yaml, files: 'sample/t1.rb', pathmap: 'tmp/%f.yaml', extras: '%X.yaml')
    #   end
    # end
    def initialize(name = nil)
      @tasks = []
      @spec_task = nil

      last_desc = ::Rake.application.last_description
      desc nil

      yield self if block_given?

      if cfndsl_opts
        desc last_desc if last_desc
        task(name || :generate) { |_t, _args| cfndsl_opts[:files].each { |opts| generate(opts) } }
      else
        define_base_tasks(name || :generate, last_desc)
      end
    end

    # Use a custom specification file
    #
    # This specification file will be used for any generation tasks
    #
    # Creates a file task to download from upstream source, with an optional additional named task that depends on it.
    #
    # The minimum required version can be specified with the version parameter, which can be overriden by invoking
    # rake with the 'cfn_spec_task' argument
    #
    # @example
    # CfnDsl::RakeTask.new() do |t|
    #     t.specification(name: :update_spec, file: 'tmp/cloudformation_resources.json', version: '6.3'0)
    # end
    #
    # # rake update_spec
    # #      >> Will ensure 'tmp/cloudformation_resources.json' exists and is at least 6.3.0
    # # rake update_spec[latest]
    # #      >> Will always try to download the latest available spec
    #
    #
    # @param [String] file the number of the specification file to use
    # @param [Symbol] name A pretty name for the task to update this file from upstream source
    # @param [String] version The minimum version required, and the default version used when downloading
    #    if not specified and not overriden by 'cfn_spec_version' rake task argument
    #    then any existing file is considered sufficient, and 'latest' is the version used for downloading
    #
    def specification(name: nil, file:, version: nil)
      if name
        desc 'Update Resource Specification' unless ::Rake.application.last_description
        task name, [:cfn_spec_version] => file
      end

      @spec_task = file(file, :cfn_spec_version) do |t, args|
        update_specification(t.name, args.with_defaults(cfn_spec_version: version)[:cfn_spec_version])
      end
      @spec_task.define_singleton_method(:needed?) { true } # We always need to check
      self
    end

    # Convert DSL sources to json
    #
    # Generates file tasks for each of the matching file in the files FileList.  Each task is dependant on the source,
    #   the specification file, and the required extras files such that if the timestamp of any of these is earlier
    #   the target file will be regenerated.
    #
    # Finally task <name> is generated that depends on all the generated targets.
    #
    # @param [Symbol|String] name the name of a task that is dependant on all the files being converted
    # @param [Rake::FileList | Array<String> ] files source file list
    # @param [String] pathmap expression to map source files to target files
    # @param [Rake::Filelist|Array<String>] extras a list of files to load as external parameters
    #   Note String values containing '%' are treated as a pathmap from the source
    #   The resulting generated FileList is used as a dependency for generation so any entries not
    #   containing '*' MUST exist.
    # @param [Boolean] pretty use JSON.pretty_generate
    # @param [Hash] json_opts, other options to pass to JSON generator
    # rubocop:disable Metrics/ParameterLists
    def json(name:, files:, pathmap:, pretty: false, extras: [], **json_opts)
      json_method = pretty ? :pretty_generate : :generate
      generate_model_tasks(name: name, files: files, pathmap: pathmap, extras: extras) do |model, f|
        f.write(JSON.send(json_method, model, **json_opts))
      end
      self
    end

    # Convert DSL sources to yaml
    #
    # Generates file tasks for each of the matching file in the files FileList.  Each task is dependant on the source,
    #   the specification file, and the required extras files such that if the timestamp of any of these is earlier
    #   the target file will be regenerated.
    #
    # Finally task <name> is generated that depends on all the generated targets.
    # @param [Symbol|String] name the name of a task that is dependant on all the files being converted
    # @param [Rake::FileList | Array<String> ] files source file list
    # @param [String] pathmap expression to map source files to target files
    # @param [Rake::Filelist|Array<String>] extras a list of files to load as external parameters
    #   Note String values containing '%' are treated as a pathmap from the source
    #   The resulting generated FileList is used as a dependency for generation so any entries not
    #   containing '*' MUST exist.
    # @param [Hash] yaml_opts, other options to pass to YAML generator
    def yaml(name:, files:, pathmap:, extras: [], **yaml_opts)
      generate_model_tasks(name: name, files: files, pathmap: pathmap, extras: extras) do |model, f|
        YAML.dump(model, f, **yaml_opts)
      end
      self
    end
    # rubocop:enable Metrics/ParameterLists

    private

    attr_reader :tasks, :spec_task

    def define_base_tasks(name, description)
      return if tasks.empty?

      desc description || 'Generate Cloudformation'
      task(name || :generate, [:cfn_spec_version] => tasks)

      load_spec = task load_spec_types: [spec_task].compact do |_t, args|
        CfnDsl.specification_file = spec_task&.name || CfnDsl::LOCAL_SPEC_FILE
        require_relative 'cloudformation'
        CfnDsl::CloudFormationTemplate.check_types(file: spec_task&.name, version: @updated_version || args[:cfn_spec_version])
        verbose&.puts "Using Cloudformation types generated from #{CfnDsl::CloudFormationTemplate.template_types.values_at('File', 'Version').join(' ')}"
      end
      load_spec.define_singleton_method(:timestamp) { Rake::EARLY } # Prevent this task from causing generation tasks.

      tasks.unshift(load_spec)
    end

    def update_specification(file, minimum_version)
      if CfnDsl::Specification.update_required?(version: minimum_version, file: file)

        safe_update_embedded_spec if file == CfnDsl::LOCAL_SPEC_FILE

        result = CfnDsl.update_specification_file(file: file, version: minimum_version)
        puts "Specification #{result[:file]} updated to version #{result[:version]}"
        @updated_version = result[:version]
      elsif minimum_version
        verbose&.puts "Specification #{file} is already >= #{minimum_version}"
      end
    end

    def safe_update_embedded_spec
      return if File.fnmatch?(File.join(File.dirname(File.expand_path(Rake.application.rakefile)), '*'), CfnDsl::LOCAL_SPEC_FILE)

      raise Error, 'Refusing to update CloudFormation spec embedded in cfndsl gem'
    end

    def generate_model_tasks(name:, files:, pathmap:, extras:)
      files = Rake::FileList.new(*files) unless files.is_a?(Rake::FileList)

      tasks << task(name, [:cfn_spec_version] => files.pathmap(pathmap))

      files.each do |source|
        matched_extras = build_extras_filelist(source, extras)

        file source.pathmap(pathmap) => [source, :load_spec_types, matched_extras] do |task|
          eval_extras = matched_extras.map { |e| [:yaml, e] } # eval treats yaml and json same
          puts "Generating Cloudformation for #{source} to #{task.name}"
          model = CfnDsl.eval_file_with_extras(source, eval_extras, verbose)
          File.open(task.name, 'w') { |f| yield model, f }
        end
      end

      self
    end

    def build_extras_filelist(source, extras)
      extras = [extras] unless extras.respond_to?(:each)
      extras.each_with_object(Rake::FileList.new) do |extra, result|
        case extra
        when Rake::FileList
          result.add(extra)
        when Array
          result.add(*extra)
        when /%/
          result.add(source.pathmap(extra))
        else
          result.add(extra)
        end
      end
    end

    def verbose
      (Rake.verbose? || cfndsl_opts&.fetch(:verbose, false)) && STDERR
    end

    def generate(opts)
      log(opts)
      outputter(opts) do |output|
        if cfndsl_opts[:outformat] == 'yaml'
          data = model(opts[:filename]).to_json
          output.puts JSON.parse(data).to_yaml
        else
          output.puts cfndsl_opts[:pretty] ? JSON.pretty_generate(model(opts[:filename])) : model(opts[:filename]).to_json
        end
      end
    end

    def log(opts)
      type = opts[:output].nil? ? 'STDOUT' : opts[:output]
      verbose&.puts("Writing to #{type}")
    end

    def outputter(opts)
      opts[:output].nil? ? yield(STDOUT) : file_output(opts[:output]) { |f| yield f }
    end

    def model(filename)
      raise "#{filename} doesn't exist" unless File.exist?(filename)

      verbose&.puts("using extras #{extra}")
      CfnDsl.eval_file_with_extras(filename, extra, verbose)
    end

    def extra
      cfndsl_opts.fetch(:extras, [])
    end

    def file_output(path)
      File.open(File.expand_path(path), 'w') { |f| yield f }
    end
  end
  # rubocop:enable Metrics/ClassLength
end
