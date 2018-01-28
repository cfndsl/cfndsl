# Totally borrowed from https://github.com/danielsdeleo/deep_merge
require 'deep_merge/core'

module DeepMerge
  # Implements a deep merge with default options
  module DeepMergeHash
    # deep_merge! will merge and overwrite any unmergeables in destination hash
    def deep_merge!(source, options = {})
      default_opts = { preserve_unmergeables: false }
      DeepMerge.deep_merge!(source, self, default_opts.merge(options))
    end
  end
end

# Extends hash with deep merge
class Hash
  include DeepMerge::DeepMergeHash
end
