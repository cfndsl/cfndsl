require 'test/unit'
require 'cfndsl'

class CfnDslTest < Test::Unit::TestCase
  def test_empty_template
    x = CfnDsl::CloudFormationTemplate.new
    assert_equal '{"AWSTemplateFormatVersion":"2010-09-09"}',
        x.to_json
  end

  def test_dsl_attr_setter
    x = CfnDsl::CloudFormationTemplate.new
    x.AWSTemplateFormatVersion "AAAAAA"
    assert_equal '{"AWSTemplateFormatVersion":"AAAAAA"}',
        x.to_json
  end

  def test_dsl_content_object
    x = CfnDsl::CloudFormationTemplate.new
    out = x.Output(:Out) {
      Value "value"
      Description "desc"
    }

    test = self
    out.declare {
      test.assert_equal "value", @Value
      test.assert_equal "desc", @Description
    }

    x.declare {
      test.assert_equal 1,@Outputs.length
    }
  end

  def test_builtin_functions
    test = self
    x = CfnDsl::CloudFormationTemplate.new
    x.declare {
      fnga = FnGetAtt("A","B")
      test.assert_equal '{"Fn::GetAtt":["A","B"]}',fnga.to_json

      fnjoin = FnJoin("A",["B","C"])
      test.assert_equal '{"Fn::Join":["A",["B","C"]]}',fnjoin.to_json

      ref = Ref("X")
      test.assert_equal '{"Ref":"X"}', ref.to_json

      fnbase64 = FnBase64("A")
      test.assert_equal '{"Fn::Base64":"A"}', fnbase64.to_json

      fnfindmap = FnFindInMap( "map", "key", "value" )
      test.assert_equal '{"Fn::FindInMap":["map","key","value"]}', fnfindmap.to_json

      fngetaz = FnGetAZs("reg")
      test.assert_equal '{"Fn::GetAZs":"reg"}',fngetaz.to_json


      fnformat = FnFormat("abc%0def%1ghi%%x","A","B")
      test.assert_equal '{"Fn::Join":["",["abc","A","def","B","ghi","%","x"]]}', fnformat.to_json

    }
  end
end
