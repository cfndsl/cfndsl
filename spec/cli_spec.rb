require 'spec_helper'

describe 'cfndsl', type: :aruba do
  let(:usage) do
    <<-USAGE.gsub(/^ {6}/, '').chomp
      Usage: cfndsl [options] FILE
          -o, --output FILE                Write output to file
          -y, --yaml FILE                  Import yaml file as local variables
          -j, --json FILE                  Import json file as local variables
          -p, --pretty                     Pretty-format output JSON
          -f, --format FORMAT              Specify the output format (JSON default)
          -D, --define "VARIABLE=VALUE"    Directly set local VARIABLE as VALUE
          -v, --verbose                    Turn on verbose ouptut
          -s, --specification-file FILE    Location of Cloudformation Resource Specification file
          -u, --update-specification       Update the Cloudformation Resource Specification file
          -g RESOURCE_TYPE,RESOURCE_LOGICAL_NAME,
              --generate                   Add resource type and logical name
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

  context 'cfndsl -u' do
    it 'updates the specification file' do
      run 'cfndsl -u'
      expect(last_command_started).to have_output_on_stderr(<<-OUTPUT.gsub(/^ {8}/, '').chomp)
        Updating specification file
        Specification successfully written to #{ENV['HOME']}/.cfndsl/resource_specification.json
      OUTPUT
      expect(last_command_started).to have_exit_status(0)
    end
  end

  context 'cfndsl' do
    it 'displays the usage' do
      run 'cfndsl'
      expect(last_command_started).to have_output(usage)
      expect(last_command_started).to have_exit_status(1)
    end
  end

  context 'cfndsl --help' do
    it 'displays the usage' do
      run_simple 'cfndsl --help'
      expect(last_command_started).to have_output(usage)
    end
  end

  context 'cfndsl FILE' do
    it 'generates a JSON CloudFormation template' do
      run_simple 'cfndsl template.rb'
      expect(last_command_started).to have_output_on_stdout('{"AWSTemplateFormatVersion":"2010-09-09","Description":"default"}')
    end
  end

  context 'cfndsl FILE --pretty' do
    it 'generates a pretty JSON CloudFormation template' do
      run_simple 'cfndsl template.rb --pretty'
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
      run_simple 'cfndsl template.rb --output template.json'
      expect(read('template.json')).to eq(['{"AWSTemplateFormatVersion":"2010-09-09","Description":"default"}'])
    end
  end

  context 'cfndsl FILE --yaml FILE' do
    before { write_file('params.yaml', 'DESC: yaml') }

    it 'interpolates the YAML file in the CloudFormation template' do
      run_simple 'cfndsl template.rb --yaml params.yaml'
      expect(last_command_started).to have_output_on_stdout('{"AWSTemplateFormatVersion":"2010-09-09","Description":"yaml"}')
    end
  end

  context 'cfndsl FILE --json FILE' do
    before { write_file('params.json', '{"DESC":"json"}') }

    it 'interpolates the JSON file in the CloudFormation template' do
      run_simple 'cfndsl template.rb --json params.json'
      expect(last_command_started).to have_output_on_stdout('{"AWSTemplateFormatVersion":"2010-09-09","Description":"json"}')
    end
  end

  context 'cfndsl FILE --define VARIABLE=VALUE' do
    it 'interpolates the command line variables in the CloudFormation template' do
      run "cfndsl template.rb --define \"DESC='cli'\""
      expect(last_command_started).to have_output_on_stdout("{\"AWSTemplateFormatVersion\":\"2010-09-09\",\"Description\":\"'cli'\"}")
    end
  end

  context 'cfndsl FILE --verbose' do
    before { write_file('params.yaml', 'DESC: yaml') }

    it 'displays the variables as they are interpolated in the CloudFormation template' do
      run_simple 'cfndsl template.rb --yaml params.yaml --verbose'
      verbose = /
        Using \s specification \s file .* \.json \n
        Loading \s YAML \s file \s .* params\.yaml \n
        Loading \s template \s file \s .* template.rb \n
        Writing \s to \s STDOUT
      /x
      template = '{"AWSTemplateFormatVersion":"2010-09-09","Description":"yaml"}'
      expect(last_command_started).to have_output_on_stderr(verbose)
      expect(last_command_started).to have_output_on_stdout(template)
    end
  end
end
