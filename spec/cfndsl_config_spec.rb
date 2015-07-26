require "spec_helper"
require "cfndsl/config/loader"
require "cfndsl/config/components"

describe CfnDsl::Config::Loader do

  describe ".load" do
    context "valid config" do
      let(:config_path) { "spec/fixtures/config.yml" }
      specify { expect(subject.load(config_path)).to be_a(CfnDsl::Config::Components) }
    end

    context "invalid config" do
      context "path" do
        let(:config_path) { "path/to/nowhere.yml" }

        specify do
          expect {subject.load(config_path)}.to raise_error
        end
      end

      context "data" do
        let(:config_path) { "spec/fixtures/invalid_config.yml" }

        specify do
          expect {subject.load(config_path)}.to raise_error
        end
      end
    end
  end
end
