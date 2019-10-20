# frozen_string_literal: true

require_relative '../jsonable'
require_relative '../types'

module CfnDsl
  module AWS
    # Cloud Formation Types
    module Types
      class Type < JSONable; end
      include CfnDsl::Types # This include triggers loading and patching of the global specification
    end
  end
end
