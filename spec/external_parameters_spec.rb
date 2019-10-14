# frozen_string_literal: true

require 'spec_helper'

describe CfnDsl::ExternalParameters do
  let(:params_struct1) { "#{File.dirname(__FILE__)}/fixtures/params_struct1.yaml" }
  let(:params_struct2) { "#{File.dirname(__FILE__)}/fixtures/params_struct2.yaml" }
  let(:params_json) { "#{File.dirname(__FILE__)}/fixtures/params.json" }
  let(:params_yaml) { "#{File.dirname(__FILE__)}/fixtures/params.yaml" }

  subject do
    exp = described_class.new
    exp.set_param(:username, 'Wiz Khalifa')
    exp.set_param(:password, 'BlackAndYellow')
    exp
  end

  context '.defaults' do
    after(:example) { described_class.defaults.clear }

    it 'allows for defaults to be set for each new parameters instance' do
      described_class.defaults(reminder: 'You Know What It Is')
      expect(subject[:reminder]).to eq('You Know What It Is')
    end
  end

  context '.current' do
    it 'retrieves the current parameters instance' do
      expect(described_class.current).to be_an_instance_of(described_class)
    end
  end

  context '.refresh!' do
    it 'restores the current parameters to the defaults' do
      described_class.current.set_param(:reminder, 'You Know What It Is')
      expect(described_class.current[:reminder]).to eq('You Know What It Is')
      described_class.refresh!
      expect(described_class.current[:reminder]).to be_nil
    end
  end

  context '#set_param' do
    it 'treats keys as symbols only' do
      subject.set_param('reminder', 'You Know What It Is')
      expect(subject[:reminder]).to eq('You Know What It Is')
    end
  end

  context '#set_param_capitalised' do
    it 'treats keys as symbols only' do
      subject.set_param('Reminder', 'You Know What It Is')
      expect(subject['Reminder']).to eq('You Know What It Is')
    end
  end

  context '#set_param_merge_struct' do
    it 'treats keys as symbols only' do
      subject.load_file(params_struct1)
      subject.load_file(params_struct2)
      expect(subject['TagStandard']).to eq('Tag1' => { 'Default' => 'value1' }, 'Tag2' => { 'Default' => 'value2' })
    end
  end

  context '#get_param' do
    it 'treats keys as symbols only' do
      subject.set_param(:reminder, 'You Know What It Is')
      expect(subject.get_param('reminder')).to eq('You Know What It Is')
    end
  end

  context '#to_h' do
    it 'returns the current parameters as a Hash' do
      expect(subject.to_h).to eq(username: 'Wiz Khalifa', password: 'BlackAndYellow')
    end
  end

  context '#add_to_binding' do
    it 'defines the parameters as variables in the current binding' do
      current = binding
      subject.add_to_binding(current, nil)
      expect(current).to be_local_variable_defined(:username)
    end

    it 'prints to a logstream if given' do
      logstream = StringIO.new
      subject.add_to_binding(binding, logstream)
      logstream.rewind
      expect(logstream.read).to match('Setting local variable username to Wiz Khalifa')
    end
  end

  context '#load_file JSON' do
    it 'merges a JSON file as parameters' do
      subject.load_file(params_json)
      expect(subject[:reminder]).to eq('You Know What It Is')
    end
  end

  context '#load_file YAML' do
    it 'merges a YAML file as parameters' do
      subject.load_file(params_yaml)
      expect(subject[:reminder]).to eq('You Know What It Is')
    end
  end

  context '#[]' do
    it 'accesses the parameters like a Hash' do
      expect(subject).to respond_to(:[])
      expect(subject[:username]).to eq('Wiz Khalifa')
    end
  end

  %i[fetch keys values each_pair].each do |meth|
    context "##{meth}" do
      it "delegates the method #{meth} to the underlying parameters" do
        expect(subject.parameters).to receive(meth)
        subject.send meth
      end
    end
  end
end
