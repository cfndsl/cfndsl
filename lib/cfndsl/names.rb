module CfnDsl
  ##
  # iterates through the the valid case-insensitive names
  # for "name". 
  def self.methodNames(name)
    name_str = name.to_s
    yield name_str.to_sym
    n = name_str.dup
    n[0] = n[0].swapcase
    yield n.to_sym
  end
end
