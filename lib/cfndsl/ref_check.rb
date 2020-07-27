# frozen_string_literal: true

# This module defines some methods for walking the reference tree
# of various objects.
module RefCheck
  class SelfReference < StandardError
  end

  class NullReference < StandardError
  end

  # Build up a set of references.
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def build_references(refs = [], origin = nil, method = :all_refs)
    if respond_to?(method)
      send(method).each do |ref|
        raise SelfReference, "#{origin} references itself at #{to_json}" if origin && ref.to_s == origin
        raise NullReference, "#{origin} contains null value reference at #{to_json}" if origin && ref.nil?

        refs << ref
      end
    end

    ref_children.each do |elem|
      # Nulls are not permitted in Cloudformation templates.
      raise NullReference, "#{origin} contains null value reference at #{to_json}" if origin && elem.nil?

      elem.build_references(refs, origin, method) if elem.respond_to?(:build_references)
    end

    refs
  end
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

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

# Mixin to Hash
class Hash
  include RefCheck
  def ref_children
    values
  end
end
