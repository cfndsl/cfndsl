require "spec_helper"
require "cfndsl/config/component"

describe CfnDsl::Config::Component do
  let(:name) { "test" }
  let(:data) {
    {
      "filename" => "foo.rb",
      "output" => "bar.json"
    }
  }
  let(:subject) { described_class.new(name, data, {}) }

  describe "#extras" do
    context "default data" do
      specify { expect(subject.extras).to be_empty }
    end

    context "component data" do
      let (:expected_extras) { [{ "yaml" => "test.yml" }] }
      before(:each) do
        data["extras"] = expected_extras
      end

      specify { expect(subject.extras).to eq expected_extras }
    end
  end
end
