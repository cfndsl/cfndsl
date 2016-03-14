module RefCheck
  ##
  # This module defines some methods for walking the reference tree
  # of various objects.
  #
  def references(refs)
    ##
    # Build up a set of references.
    #
    raise 'Circular reference' if @_visited

    @_visited = true

    if respond_to?(:get_references)
      get_references.each do |ref|
        refs[ref.to_s] = 1
      end
    end

    ref_children.each do |elem|
      elem.references(refs) if elem.respond_to?(:references)
    end

    @_visited = nil

    refs
  end

  def ref_children
    []
  end
end

class Array
  include RefCheck
  def ref_children
    self
  end
end

class Hash
  include RefCheck
  def ref_children
    values
  end
end
