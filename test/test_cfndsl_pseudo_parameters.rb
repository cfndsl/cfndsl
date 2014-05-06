require 'test/unit'
require 'cfndsl'

class CfnDslTest < Test::Unit::TestCase
  def test_pseudo_parameters
    test = self
    x = CfnDsl::CloudFormationTemplate.new

    x.declare {

      [
        'AWS::AccountId',
        'AWS::NotificationARNs',
        'AWS::NoValue',
        'AWS::Region',
        'AWS::StackId',
        'AWS::StackName'
      ].each do |param|

        ref = Ref(param)
        test.assert_equal "{\"Ref\":\"#{param}\"}",ref.to_json

        refs = ref.references({})
        test.assert_equal( true, refs.has_key?(param) )
      end

    }

  end
end

