# rubocop:disable Metrics/AbcSize, Metrics/BlockNesting, Metrics/CyclomaticComplexity, Metrics/MethodLength
# rubocop:disable Metrics/ModuleLength, Metrics/PerceivedComplexity, Style/IfInsideElse, Style/Semicolon
#
# Totally borrowed from https://github.com/danielsdeleo/deep_merge
module DeepMerge
  class InvalidParameter < StandardError; end

  DEFAULT_FIELD_KNOCKOUT_PREFIX = '--'.freeze

  # Deep Merge core documentation.
  # deep_merge! method permits merging of arbitrary child elements. The two top level
  # elements must be hashes. These hashes can contain unlimited (to stack limit) levels
  # of child elements. These child elements to not have to be of the same types.
  # Where child elements are of the same type, deep_merge will attempt to merge them together.
  # Where child elements are not of the same type, deep_merge will skip or optionally overwrite
  # the destination element with the contents of the source element at that level.
  # So if you have two hashes like this:
  #   source = {:x => [1,2,3], :y => 2}
  #   dest =   {:x => [4,5,'6'], :y => [7,8,9]}
  #   dest.deep_merge!(source)
  #   Results: {:x => [1,2,3,4,5,'6'], :y => 2}
  # By default, "deep_merge!" will overwrite any unmergeables and merge everything else.
  # To avoid this, use "deep_merge" (no bang/exclamation mark)
  #
  # Options:
  #   Options are specified in the last parameter passed, which should be in hash format:
  #   hash.deep_merge!({:x => [1,2]}, {:knockout_prefix => '--'})
  #   :preserve_unmergeables  DEFAULT: false
  #      Set to true to skip any unmergeable elements from source
  #   :knockout_prefix        DEFAULT: nil
  #      Set to string value to signify prefix which deletes elements from existing element
  #   :overwrite_arrays       DEFAULT: false
  #      Set to true if you want to avoid merging arrays
  #   :sort_merged_arrays     DEFAULT: false
  #      Set to true to sort all arrays that are merged together
  #   :unpack_arrays          DEFAULT: nil
  #      Set to string value to run "Array::join" then "String::split" against all arrays
  #   :merge_hash_arrays      DEFAULT: false
  #      Set to true to merge hashes within arrays
  #   :keep_array_duplicates  DEFAULT: false
  #      Set to true to preserve duplicate array entries
  #   :merge_debug            DEFAULT: false
  #      Set to true to get console output of merge process for debugging
  #
  # Selected Options Details:
  # :knockout_prefix => The purpose of this is to provide a way to remove elements
  #   from existing Hash by specifying them in a special way in incoming hash
  #    source = {:x => ['--1', '2']}
  #    dest   = {:x => ['1', '3']}
  #    dest.ko_deep_merge!(source)
  #    Results: {:x => ['2','3']}
  #   Additionally, if the knockout_prefix is passed alone as a string, it will cause
  #   the entire element to be removed:
  #    source = {:x => '--'}
  #    dest   = {:x => [1,2,3]}
  #    dest.ko_deep_merge!(source)
  #    Results: {:x => ""}
  # :unpack_arrays => The purpose of this is to permit compound elements to be passed
  #   in as strings and to be converted into discrete array elements
  #   irsource = {:x => ['1,2,3', '4']}
  #   dest   = {:x => ['5','6','7,8']}
  #   dest.deep_merge!(source, {:unpack_arrays => ','})
  #   Results: {:x => ['1','2','3','4','5','6','7','8'}
  #   Why: If receiving data from an HTML form, this makes it easy for a checkbox
  #    to pass multiple values from within a single HTML element
  #
  # :merge_hash_arrays => merge hashes within arrays
  #   source = {:x => [{:y => 1}]}
  #   dest   = {:x => [{:z => 2}]}
  #   dest.deep_merge!(source, {:merge_hash_arrays => true})
  #   Results: {:x => [{:y => 1, :z => 2}]}
  #
  # :keep_array_duplicates => merges arrays within hashes but keeps duplicate elements
  #   source = {:x => {:y => [1,2,2,2,3]}}
  #   dest   = {:x => {:y => [4,5,6]}}
  #   dest.deep_merge!(source, {:keep_array_duplicates => true})
  #   Results: {:x => {:y => [1,2,2,2,3,4,5,6]}}
  #
  # There are many tests for this library - and you can learn more about the features
  # and usages of deep_merge! by just browsing the test examples
  def self.deep_merge!(source, dest, options = {})
    # turn on this line for stdout debugging text
    merge_debug = options[:merge_debug] || false
    overwrite_unmergeable = !options[:preserve_unmergeables]
    knockout_prefix = options[:knockout_prefix] || nil
    raise InvalidParameter, 'knockout_prefix cannot be an empty string in deep_merge!' if knockout_prefix == ''
    raise InvalidParameter, 'overwrite_unmergeable must be true if knockout_prefix is specified in deep_merge!' if knockout_prefix && !overwrite_unmergeable
    # if present: we will split and join arrays on this char before merging
    array_split_char = options[:unpack_arrays] || false
    # request that we avoid merging arrays
    overwrite_arrays = options[:overwrite_arrays] || false
    # request that we sort together any arrays when they are merged
    sort_merged_arrays = options[:sort_merged_arrays] || false
    # request that arrays of hashes are merged together
    merge_hash_arrays = options[:merge_hash_arrays] || false
    # request to extend existing arrays, instead of overwriting them
    extend_existing_arrays = options[:extend_existing_arrays] || false
    # request that arrays keep duplicate elements
    keep_array_duplicates = options[:keep_array_duplicates] || false
    # request that nil values are merged or skipped (Skipped/false by default)
    merge_nil_values = options[:merge_nil_values] || false

    di = options[:debug_indent] || ''
    # do nothing if source is nil
    return dest if !merge_nil_values && source.nil?
    # if dest doesn't exist, then simply copy source to it
    if !dest && overwrite_unmergeable
      dest = source; return dest
    end

    puts "#{di}Source class: #{source.class.inspect} :: Dest class: #{dest.class.inspect}" if merge_debug
    if source.is_a?(Hash)
      puts "#{di}Hashes: #{source.inspect} :: #{dest.inspect}" if merge_debug
      source.each do |src_key, src_value|
        if dest.is_a?(Hash)
          puts "#{di} looping: #{src_key.inspect} => #{src_value.inspect} :: #{dest.inspect}" if merge_debug
          if dest[src_key]
            puts "#{di} ==>merging: #{src_key.inspect} => #{src_value.inspect} :: #{dest[src_key].inspect}" if merge_debug
            dest[src_key] = deep_merge!(src_value, dest[src_key], options.merge(debug_indent: di + '  '))
          else # dest[src_key] doesn't exist so we want to create and overwrite it (but we do this via deep_merge!)
            puts "#{di} ==>merging over: #{src_key.inspect} => #{src_value.inspect}" if merge_debug
            # note: we rescue here b/c some classes respond to "dup" but don't implement it (Numeric, TrueClass, FalseClass, NilClass among maybe others)
            begin
              src_dup = src_value.dup # we dup src_value if possible because we're going to merge into it (since dest is empty)
            rescue TypeError
              src_dup = src_value
            end
            dest[src_key] = deep_merge!(src_value, src_dup, options.merge(debug_indent: di + '  '))
          end
        elsif dest.is_a?(Array) && extend_existing_arrays
          dest.push(source)
        else # dest isn't a hash, so we overwrite it completely (if permitted)
          if overwrite_unmergeable
            puts "#{di}  overwriting dest: #{src_key.inspect} => #{src_value.inspect} -over->  #{dest.inspect}" if merge_debug
            dest = overwrite_unmergeables(source, dest, options)
          end
        end
      end
    elsif source.is_a?(Array)
      puts "#{di}Arrays: #{source.inspect} :: #{dest.inspect}" if merge_debug
      if overwrite_arrays
        puts "#{di} overwrite arrays" if merge_debug
        dest = source
      else
        # if we are instructed, join/split any source arrays before processing
        if array_split_char
          puts "#{di} split/join on source: #{source.inspect}" if merge_debug
          source = source.join(array_split_char).split(array_split_char)
          dest = dest.join(array_split_char).split(array_split_char) if dest.is_a?(Array)
        end
        # if there's a naked knockout_prefix in source, that means we are to truncate dest
        if knockout_prefix && source.index(knockout_prefix)
          dest = clear_or_nil(dest); source.delete(knockout_prefix)
        end
        if dest.is_a?(Array)
          if knockout_prefix
            print "#{di} knocking out: " if merge_debug
            # remove knockout prefix items from both source and dest
            source.delete_if do |ko_item|
              retval = false
              item = ko_item.respond_to?(:gsub) ? ko_item.gsub(/^#{knockout_prefix}/, '') : ko_item
              if item != ko_item
                print "#{ko_item} - " if merge_debug
                dest.delete(item)
                dest.delete(ko_item)
                retval = true
              end
              retval
            end
            puts if merge_debug
          end
          puts "#{di} merging arrays: #{source.inspect} :: #{dest.inspect}" if merge_debug
          source_all_hashes = source.all? { |i| i.is_a?(Hash) }
          dest_all_hashes = dest.all? { |i| i.is_a?(Hash) }
          if merge_hash_arrays && source_all_hashes && dest_all_hashes
            # merge hashes in lists
            list = []
            dest.each_index do |i|
              list[i] = deep_merge!(source[i] || {}, dest[i],
                                    options.merge(debug_indent: di + '  '))
            end
            list += source[dest.count..-1] if source.count > dest.count
            dest = list
          elsif keep_array_duplicates
            dest = dest.concat(source)
          else
            dest |= source
          end
          dest.sort! if sort_merged_arrays
        elsif overwrite_unmergeable
          puts "#{di} overwriting dest: #{source.inspect} -over-> #{dest.inspect}" if merge_debug
          dest = overwrite_unmergeables(source, dest, options)
        end
      end
    else # src_hash is not an array or hash, so we'll have to overwrite dest
      if dest.is_a?(Array) && extend_existing_arrays
        dest.push(source)
      else
        puts "#{di}Others: #{source.inspect} :: #{dest.inspect}" if merge_debug
        dest = overwrite_unmergeables(source, dest, options)
      end
    end
    puts "#{di}Returning #{dest.inspect}" if merge_debug
    dest
  end

  # allows deep_merge! to uniformly handle overwriting of unmergeable entities
  def self.overwrite_unmergeables(source, dest, options)
    merge_debug = options[:merge_debug] || false
    overwrite_unmergeable = !options[:preserve_unmergeables]
    knockout_prefix = options[:knockout_prefix] || false
    di = options[:debug_indent] || ''
    if knockout_prefix && overwrite_unmergeable
      src_tmp = if source.is_a?(String) # remove knockout string from source before overwriting dest
                  source.gsub(/^#{knockout_prefix}/, '')
                elsif source.is_a?(Array) # remove all knockout elements before overwriting dest
                  source.delete_if { |ko_item| ko_item.is_a?(String) && ko_item.match(/^#{knockout_prefix}/) }
                else
                  source
                end
      if src_tmp == source # if we didn't find a knockout_prefix then we just overwrite dest
        puts "#{di}#{src_tmp.inspect} -over-> #{dest.inspect}" if merge_debug
        dest = src_tmp
      else # if we do find a knockout_prefix, then we just delete dest
        puts "#{di}\"\" -over-> #{dest.inspect}" if merge_debug
        dest = ''
      end
    elsif overwrite_unmergeable
      dest = source
    end
    dest
  end

  def self.clear_or_nil(obj)
    if obj.respond_to?(:clear)
      obj.clear
    else
      obj = nil
    end
    obj
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/BlockNesting, Metrics/CyclomaticComplexity, Metrics/MethodLength
# rubocop:enable Metrics/ModuleLength, Metrics/PerceivedComplexity, Style/IfInsideElse, Style/Semicolon
