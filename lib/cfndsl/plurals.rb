# frozen_string_literal: true

module CfnDsl
  # Plural names for lists of content objects
  module Plurals
    module_function

    @plurals = {
      'AssumeRolePolicyDocument' => 'AssumeRolePolicyDocument',
      'CreationPolicy' => 'CreationPolicy',
      'DBSecurityGroupIngress' => 'DBSecurityGroupIngress',
      'Metadata' => 'Metadata',
      'Policy' => 'Policies',
      'PolicyDocument' => 'PolicyDocument',
      'Property' => 'Properties',
      'SecurityGroupEgress' => 'SecurityGroupEgress',
      'SecurityGroupIngress' => 'SecurityGroupIngress',
      'UpdatePolicy' => 'UpdatePolicy'
    }
    @singles = @plurals.invert

    def pluralize(name)
      @plurals.fetch(name.to_s) { |key| key + 's' }
    end

    def singularize(name)
      @singles.fetch(name.to_s) do |key|
        case key
        when /List$/
          key[0..-5]
        when /ies$/
          key[0..-4] + 'y'
        when /s$/
          key[0..-2]
        else
          key
        end
      end
    end
  end
end
