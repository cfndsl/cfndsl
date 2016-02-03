CloudFormation {
  DESCRIPTION ||= "lambda description"

  Description DESCRIPTION

  Parameter('Role') { Type "String" }

  Resource('LambdaFunction') {
    Type 'AWS::Lambda::Function'
    Property('Handler','index.handler')
    Property('Role',Ref('Role'))
    Property('Code',{
      S3Bucket: "lambda-functions",
      S3Key: "amilookup.zip"
    })
    Property('Runtime','nodejs')
    Property('Timeout','25')
  }

  Resource('EventSourceMapping') {
    Type 'AWS::Lambda::EventSourceMapping'
    Property('EventSourceArn', FnJoin('',["arn:aws:kinesis:", Ref('AWS::Region'), ":", Ref('AWS::AccountId'), ':stream/test']))
    Property('FunctionName', FnGetAtt('LambdaFunction', 'Arn'))
    Property('StartingPosition', 'TRIM_HORIZON')
  }

  Resource('LambdaInvokePermission') {
    Type 'AWS::Lambda::Permission'
    Property('FunctionName', FnGetAtt('LambdaFunction', 'Arn'))
    Property('Action', [
      'lambda:InvokeFunction'
    ])
    Property('Principal', 's3.amazonaws.com')
    Property('SourceAccount', Ref('AWS::AccountId'))

  }

}
