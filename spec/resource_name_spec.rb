# frozen_string_literal: true

require 'spec_helper'

describe 'cfndsl', type: :aruba do
  let(:template_content) do
    <<-TEMPLATE.gsub(/^ {6}/, '')
      CloudFormation do
        EC2_Instance(:my_instance) do
        end
      end
    TEMPLATE
  end
  before(:each) { write_file('template.rb', template_content) }
  context 'cfndsl FILE' do
    it 'errors because the name is invalid' do
      run_command 'cfndsl template.rb'
      expect(last_command_started).to have_output_on_stderr('Resource name: my_instance is invalid')
    end
  end
end
