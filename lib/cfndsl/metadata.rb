module CfnDsl
  # Handles metadata objects for AWS launch configurations
  #
  # Usage
  # Metadata("AWS::CloudFormation::Init", {
  # "config" => {
  #  "files"    => {
  #    "/cfn.ini" => {
  #      "content" => "test"
  #     }
  #    }
  #  }
  # })
  #
  class MetadataDefinition < JSONable
    include JSONSerialisableObject

    attr_reader :value

    def initialize(value)
      @value = value
    end
  end
end
