require "spec_helper"
require "cfndsl/config/components"
require "cfndsl/config/component"

describe CfnDsl::Config::Components do
  let(:config_path) { YAML.load_file("spec/fixtures/config.yml") }
  let(:subject) { described_class.new(config_path) }

  describe "#extras" do
    specify { expect(subject.extras[0]).to have_key("yaml") }
  end

  describe "#components[0]" do
    specify { expect(subject.components[0]).to be_a(CfnDsl::Config::Component) }
  end

end
