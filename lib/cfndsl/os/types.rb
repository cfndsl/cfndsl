# frozen_string_literal: true

require 'cfndsl/types'

module CfnDsl
  module OS
    # Open Stack Types
    module Types
      TYPE_PREFIX = 'os'
      class Type < JSONable; end
      include CfnDsl::Types
    end
  end
end
