require 'cfndsl/types'

module CfnDsl
  module AWS
    # Cloud Formation Types
    module Types
      TYPE_PREFIX = 'aws'.freeze
      class Type < JSONable; end
      include CfnDsl::Types
    end
  end
end
