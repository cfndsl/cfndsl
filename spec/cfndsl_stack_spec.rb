require 'spec_helper'

describe 'Stacked' do
  let(:template) { File.expand_path('../fixtures/stacked.rb', __FILE__) }
  let(:subject) { CfnDsl.eval_file_with_extras(template).to_json }

  it 'renders a valid json' do
    expect(subject).to eq('{"AWSTemplateFormatVersion":"2010-09-09","Description":"Test","Parameters":{"One":{"Type":"String"}}}')
  end
end
