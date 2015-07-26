require "cfndsl/config/components"
require "yaml"

module CfnDsl
  module Config
    module Loader

      def self.load(path = "./.cfndsl.yml")
        absolute_path = File.expand_path path
        fail "The path '#{absolute_path}' doesn't exist" unless File.exists? absolute_path

        CfnDsl::Config::Components.new(
          YAML.load_file(path)
        )
      end

    end
  end
end
