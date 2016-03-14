module CfnDsl
  ##
  # iterates through the the valid case-insensitive names
  # for "name"
  def self.method_names(name, &block)
    if block
      name_str = name.to_s
      yield name_str.to_sym
      n = name_str.dup
      n[0] = n[0].swapcase
      yield n.to_sym
    else
      result = [name.dup, name.dup]
      result[1][0] = result[1][0].swapcase
      return result
    end
  end
end
