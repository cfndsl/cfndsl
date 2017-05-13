module CfnDsl
  # Set global variables
  class Globals
    class << self
      def reserved_items
        %w[Resource Parameter Output].freeze
      end
    end
  end
end
