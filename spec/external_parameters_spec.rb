require 'spec_helper'

describe CfnDsl::ExternalParameters do
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

  %i[fetch keys values each_pair].each do |meth|
    context "##{meth}" do
      it "delegates the method #{meth} to the underlying parameters" do
        expect(subject.parameters).to receive(meth)
        subject.send meth
      end
    end
  end
end
