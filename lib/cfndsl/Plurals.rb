module CfnDsl
  module Plurals
    ##
    # Plural names for lists of content objects
    #
    
    @@plurals = { 
      "Metadata" => "Metadata", 
      "Property" => "Properties",
      "Policy" => "Policies",
      "PolicyDocument" => "PolicyDocument",
      "AssumeRolePolicyDocument" => "AssumeRolePolicyDocument",
      "SecurityGroupIngress" => "SecurityGroupIngress",
      "SecurityGroupEgress" => "SecurityGroupEgress",
      "DBSecurityGroupIngress" => "DBSecurityGroupIngress",
      "UpdatePolicy" => "UpdatePolicy"
    }
    
    @@singles = {}
    @@plurals.each_pair { |key,val| @@singles[val] = key }

    def self.pluralize(name)
      name = name.to_s
      return @@plurals[name] if( @@plurals.has_key? name )
      return "#{name}s"
    end

    def self.singularize(name)
      name = name.to_s
      return @@singles[name] if( @@singles.has_key? name )
      return name[0..-2]
    end
  end
end
