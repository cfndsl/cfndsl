require 'cfndsl/types'

module CfnDsl
  module OS
    module Types
      TYPE_PREFIX = 'os'.freeze
      class Type < JSONable; end
      include CfnDsl::Types
    end
  end
end
