# frozen_string_literal: true

CloudFormation do
  S3_Bucket('Bucket') do
    BucketName 'MyBucket'
    VersioningConfiguration(Status: 'Enabled')
    NotificationConfiguration(
      LambdaConfigurations: [
        {
          Function: 'MyLambdaFunction',
          Event: 'S3:ObjectCreated:*'
        },
        {
          Function: 'MyLambdaFunction',
          Event: 's3:ObjectRemoved:*'
        }
      ],
      QueueConfigurations: [
        {
          Queue: 'SQSQueue',
          Event: 'S3:ObjectCreated:*'
        }
      ],
      TopicConfigurations: [
        {
          Topic: 'SNSTopic',
          Event: 'S3:ObjectCreated:*'
        }
      ]
    )
    WebsiteConfiguration(
      ErrorDocument: 'error.htm',
      IndexDocument: 'index.htm',
      RoutingRules: [
        {
          RoutingRuleCondition: {
            HttpErrorCodeReturnedEquals: '404',
            KeyPrefixEquals: 'out1/'
          },
          RedirectRule: {
            HostName: 'ec2-11-22-333-44.compute-1.amazonaws.com',
            ReplaceKeyPrefixWith: 'report-404/'
          }
        }
      ]
    )
  end
end
