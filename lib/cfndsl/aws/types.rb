require 'cfndsl/types'

module CfnDsl
  module AWS
    module Types
      TYPE_PREFIX = 'aws'.freeze
      class Type < JSONable; end
      include CfnDsl::Types
    end
  end
end
