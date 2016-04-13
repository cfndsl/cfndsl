module CfnDsl
  # Plural names for lists of content objects
  module Plurals
    @plurals = {
      'Metadata' => 'Metadata',
      'Property' => 'Properties',
      'Policy' => 'Policies',
      'PolicyDocument' => 'PolicyDocument',
      'AssumeRolePolicyDocument' => 'AssumeRolePolicyDocument',
      'SecurityGroupIngress' => 'SecurityGroupIngress',
      'SecurityGroupEgress' => 'SecurityGroupEgress',
      'DBSecurityGroupIngress' => 'DBSecurityGroupIngress',
      'UpdatePolicy' => 'UpdatePolicy',
      'CreationPolicy' => 'CreationPolicy'
    }

    @singles = {}
    @plurals.each_pair { |key, val| @singles[val] = key }

    def self.pluralize(name)
      name = name.to_s
      return @plurals[name] if @plurals.key?(name)

      "#{name}s"
    end

    def self.singularize(name)
      name = name.to_s
      return @singles[name] if @singles.key?(name)

      name[0..-2]
    end
  end
end
