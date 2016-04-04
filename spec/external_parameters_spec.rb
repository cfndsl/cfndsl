require 'spec_helper'

describe CfnDsl::ExternalParameters do
  subject do
    exp = described_class.new
    exp.set_param(:username, 'Wiz Khalifa')
    exp.set_param(:password, 'BlackAndYellow')
    exp
  end

  context '#set_param' do
    it 'treats keys as symbols only' do
      subject.set_param('reminder', 'You Know What It Is')
      expect(subject[:reminder]).to eq('You Know What It Is')
    end
  end

  context '#get_param' do
    it 'treats keys as symbols only' do
      subject.set_param(:reminder, 'You Know What It Is')
      expect(subject.get_param('reminder')).to eq('You Know What It Is')
    end
  end

  context '#to_hash' do
    it 'returns the current parameters as a Hash' do
      expect(subject.to_hash).to eq(username: 'Wiz Khalifa', password: 'BlackAndYellow')
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

  context '#load_file JSON', type: :aruba do
    before { write_file('params.json', '{"reminder":"You Know What It Is"}') }

    it 'merges a JSON file as parameters' do
      subject.load_file File.join(expand_path('./params.json'))
      expect(subject[:reminder]).to eq('You Know What It Is')
    end
  end

  context '#load_file YAML', type: :aruba do
    before { write_file('params.yaml', '{"reminder":"You Know What It Is"}') }

    it 'merges a YAML file as parameters' do
      subject.load_file File.join(expand_path('./params.yaml'))
      expect(subject[:reminder]).to eq('You Know What It Is')
    end
  end

  context '#[]' do
    it 'accesses the parameters like a Hash' do
      expect(subject).to respond_to(:[])
      expect(subject[:username]).to eq('Wiz Khalifa')
    end
  end
end
