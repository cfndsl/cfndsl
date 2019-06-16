# frozen_string_literal: true

require 'spec_helper'

WORKING_SPEC_VERSION = '2.19.0'

describe 'cfndsl', type: :aruba do
  let(:usage) do
    <<-USAGE.gsub(/^ {6}/, '').chomp
      Usage: cfndsl [options] FILE
          -o, --output FILE                Write output to file
          -y, --yaml FILE                  Import yaml file as local variables
          -r, --ruby FILE                  Evaluate ruby file before template
          -j, --json FILE                  Import json file as local variables
          -p, --pretty                     Pretty-format output JSON
          -f, --format FORMAT              Specify the output format (JSON default)
          -D, --define "VARIABLE=VALUE"    Directly set local VARIABLE as VALUE
          -v, --verbose                    Turn on verbose ouptut
          -b, --disable-binding            Disable binding configuration
          -m, --disable-deep-merge         Disable deep merging of yaml
          -s, --specification-file FILE    Location of Cloudformation Resource Specification file
          -u [VERSION],                    Update the Resource Specification file to latest, or specific version
              --update-specification
          -g RESOURCE_TYPE,RESOURCE_LOGICAL_NAME,
              --generate                   Add resource type and logical name
          -a, --assetversion               Print out the specification version
          -l, --list                       List supported resources
          -h, --help                       Display this screen
    USAGE
  end

  let(:template_content) do
    <<-TEMPLATE.gsub(/^ {6}/, '')
      CloudFormation do
        Description(external_parameters[:DESC] || 'default')
      end
    TEMPLATE
  end

  before(:each) { write_file('template.rb', template_content) }

  context "cfndsl -u #{WORKING_SPEC_VERSION}" do
    it 'updates the specification file' do
      run_command "cfndsl -u #{WORKING_SPEC_VERSION}"
      expect(last_command_started).to have_output_on_stderr(<<-OUTPUT.gsub(/^ {8}/, '').chomp)
        Updating specification file
        Specification successfully written to #{ENV['HOME']}/.cfndsl/resource_specification.json
      OUTPUT
      expect(last_command_started).to have_exit_status(0)
    end
  end

  context 'cfndsl -u' do
    it 'updates the specification file' do
      run_command 'cfndsl -u'
      expect(last_command_started).to have_output_on_stderr(<<-OUTPUT.gsub(/^ {8}/, '').chomp)
        Updating specification file
        Specification successfully written to #{ENV['HOME']}/.cfndsl/resource_specification.json
      OUTPUT
      expect(last_command_started).to have_exit_status(0)
    end
  end

  context 'cfndsl -a' do
    it 'prints out the specification file version' do
      run_command 'cfndsl -a'
      expect(last_command_started).to have_output_on_stderr(/([0-9]+\.){2}[0-9]+/)
      expect(last_command_started).to have_exit_status(0)
    end
  end

  context 'cfndsl' do
    it 'displays the usage' do
      run_command 'cfndsl'
      expect(last_command_started).to have_output(usage)
      expect(last_command_started).to have_exit_status(1)
    end
  end

  context 'cfndsl --help' do
    it 'displays the usage' do
      run_command_and_stop 'cfndsl --help'
      expect(last_command_started).to have_output(usage)
    end
  end

  context 'cfndsl FILE' do
    it 'gives a deprecation warning about bindings' do
      run_command_and_stop 'cfndsl template.rb'
      expect(last_command_started).to have_output_on_stderr(<<-WARN.gsub(/^ {8}/, '').chomp)
        The creation of constants as config is deprecated!
        Please switch to the #external_parameters method within your templates to access variables
        See https://github.com/cfndsl/cfndsl/issues/170
        Use the --disable-binding flag to suppress this message
      WARN
    end

    it 'generates a JSON CloudFormation template' do
      run_command_and_stop 'cfndsl template.rb'
      expect(last_command_started).to have_output_on_stdout('{"AWSTemplateFormatVersion":"2010-09-09","Description":"default"}')
    end
  end

  context 'cfndsl FILE --pretty' do
    it 'generates a pretty JSON CloudFormation template' do
      run_command_and_stop 'cfndsl template.rb --pretty'
      expect(last_command_started).to have_output_on_stdout(<<-OUTPUT.gsub(/^ {8}/, '').chomp)
        {
          "AWSTemplateFormatVersion": "2010-09-09",
          "Description": "default"
        }
      OUTPUT
    end
  end

  context 'cfndsl FILE --output FILE' do
    it 'writes the JSON CloudFormation template to a file' do
      run_command_and_stop 'cfndsl template.rb --output template.json'
      expect(read('template.json')).to eq(['{"AWSTemplateFormatVersion":"2010-09-09","Description":"default"}'])
    end
  end

  context 'cfndsl FILE --yaml FILE' do
    before { write_file('params.yaml', 'DESC: yaml') }

    it 'interpolates the YAML file in the CloudFormation template' do
      run_command_and_stop 'cfndsl template.rb --yaml params.yaml'
      expect(last_command_started).to have_output_on_stdout('{"AWSTemplateFormatVersion":"2010-09-09","Description":"yaml"}')
    end
  end

  context 'cfndsl FILE --json FILE' do
    before { write_file('params.json', '{"DESC":"json"}') }

    it 'interpolates the JSON file in the CloudFormation template' do
      run_command_and_stop 'cfndsl template.rb --json params.json'
      expect(last_command_started).to have_output_on_stdout('{"AWSTemplateFormatVersion":"2010-09-09","Description":"json"}')
    end
  end

  context 'cfndsl FILE --ruby FILE' do
    let(:template_content) do
      <<-TEMPLATE.gsub(/^ {8}/, '')
        CloudFormation do
          DESC = 'default' unless defined? DESC
          Description DESC
        end
      TEMPLATE
    end

    before(:each) { write_file('params.rb', 'DESC = "ruby"') }

    it 'interpolates the Ruby file in the CloudFormation template' do
      run_command_and_stop 'cfndsl template.rb --ruby params.rb'
      expect(last_command_started).to have_output_on_stdout('{"AWSTemplateFormatVersion":"2010-09-09","Description":"ruby"}')
    end

    it 'gives a deprecation warning and does not interpolate if bindings are disabled' do
      run_command_and_stop 'cfndsl template.rb --ruby params.rb --disable-binding --verbose'
      deprecation_warning = /Interpreting Ruby files was disabled\. .*params.rb will not be read/
      expect(last_command_started).to have_output_on_stderr(deprecation_warning)
      expect(last_command_started).to have_output_on_stdout('{"AWSTemplateFormatVersion":"2010-09-09","Description":"default"}')
    end
  end

  context 'cfndsl FILE --define VARIABLE=VALUE' do
    it 'interpolates the command line variables in the CloudFormation template' do
      run_command "cfndsl template.rb --define \"DESC='cli'\""
      expect(last_command_started).to have_output_on_stdout("{\"AWSTemplateFormatVersion\":\"2010-09-09\",\"Description\":\"'cli'\"}")
    end
  end

  context 'cfndsl FILE --verbose' do
    before { write_file('params.yaml', 'DESC: yaml') }

    it 'displays the variables as they are interpolated in the CloudFormation template' do
      run_command_and_stop 'cfndsl template.rb --yaml params.yaml --verbose'
      verbose = %r{The creation of constants as config is deprecated!
Please switch to the #external_parameters method within your templates to access variables
See https://github.com/cfndsl/cfndsl/issues/170
Use the --disable-binding flag to suppress this message
Using specification file .*\.json
Loading YAML file .*params\.yaml
Setting local variable DESC to yaml
Loading template file .*template\.rb
Writing to STDOUT}
      template = '{"AWSTemplateFormatVersion":"2010-09-09","Description":"yaml"}'
      expect(last_command_started).to have_output_on_stderr(verbose)
      expect(last_command_started).to have_output_on_stdout(template)
    end
  end
end
