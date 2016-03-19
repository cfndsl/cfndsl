# This module defines some methods for walking the reference tree
# of various objects.
module RefCheck
  # Build up a set of references.
  def build_references(refs)
    raise 'Circular reference' if @_visited

    @_visited = true

    if respond_to?(:all_refs)
      all_refs.each do |ref|
        refs[ref.to_s] = 1
      end
    end

    ref_children.each do |elem|
      elem.build_references(refs) if elem.respond_to?(:build_references)
    end

    @_visited = nil

    refs
  end

  def ref_children
    []
  end
end

# Mixin to Array
class Array
  include RefCheck
  def ref_children
    self
  end
end

# Mixin to Array
class Hash
  include RefCheck
  def ref_children
    values
  end
end
