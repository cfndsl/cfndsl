# Method name helper
module CfnDsl
  module_function

  # iterates through the the valid case-insensitive names
  # for "name"
  def method_names(name)
    name_str = name.to_s.dup
    names = [name_str, name_str.gsub(/^\w/, &:swapcase)]
    block_given? ? names.each { |n| yield n.to_sym } : names
  end
end
