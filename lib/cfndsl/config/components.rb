require "cfndsl/config/component"

module CfnDsl
  module Config
    class Components
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def extras
        data["extras"]
      end

      def components
        data["components"].map do |name, data|
          CfnDsl::Config::Component.new(
            name,
            data,
            extras
          )
        end
      end
    end
  end
end


