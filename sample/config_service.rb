CloudFormation do
  AWSTemplateFormatVersion '2010-09-09'

  Description 'Creates SNS, SQS, S3 bucket and enables AWS Config.'

  Queue('ConfigServiceQueue') do
    QueueName 'ConfigServiceQueue'
  end

  Bucket('ConfigServiceBucket') do
  end

  Policy('ConfigServiceS3BucketAccessPolicy') do
    PolicyName 'ConfigServiceS3BucketAccessPolicy'
    PolicyDocument(
      'Version' => '2012-10-17',
      'Statement' =>
      [
        {
          'Effect' => 'Allow',
          'Action' => ['s3:PutObject'],
          'Resource' => FnJoin('', ['arn:aws:s3:::', Ref('ConfigServiceBucket'), '/AWSLogs/', Ref('AWS::AccountId'), '/*']),
          'Condition' =>
          {
            'StringLike' =>
            {
              's3:x-amz-acl' => 'bucket-owner-full-control'
            }
          }
        },
        {
          'Effect' => 'Allow',
          'Action' => ['s3:GetBucketAcl'],
          'Resource' => FnJoin('', ['arn:aws:s3:::', Ref('ConfigServiceBucket')])
        }
      ]
    )
    Role Ref('ConfigServiceIAMRole')
  end

  Role('ConfigServiceIAMRole') do
    AssumeRolePolicyDocument(
      'Version' => '2012-10-17',
      'Statement' => [
        {
          'Effect' => 'Allow',
          'Principal' => {
            'Service' => 'config.amazonaws.com'
          },
          'Action' => 'sts:AssumeRole'
        }
      ]
    )
    ManagedPolicyArns(
      [
        'arn:aws:iam::aws:policy/service-role/AWSConfigRole'
      ]
    )
  end

  Topic('ConfigServiceTopic') do
    DisplayName 'ConfigSvc'
    Subscription [{
      'Endpoint' => FnGetAtt('ConfigServiceQueue', 'Arn'),
      'Protocol' => 'sqs'
    }]
  end

  Policy('ConfigServiceSNSTopicAccessPolicy') do
    PolicyName 'ConfigServiceSNSTopicAccessPolicy'
    PolicyDocument(
      'Version' => '2012-10-17',
      'Statement' =>
      [
        {
          'Effect' => 'Allow',
          'Action' => 'sns:Publish',
          'Resource' => Ref('ConfigServiceTopic')
        }
      ]
    )
    Role Ref('ConfigServiceIAMRole')
  end

  QueuePolicy('ConfigServiceQueuePolicy') do
    PolicyDocument(
      'Version' => '2012-10-17',
      'Statement' => [
        {
          'Sid' => 'Allow-SendMessage-To-ConfigService-Queue-From-SNS-Topic',
          'Effect' => 'Allow',
          'Principal' => '*',
          'Action' => ['sqs:SendMessage'],
          'Resource' => '*',
          'Condition' => {
            'ArnEquals' => {
              'aws:SourceArn' => Ref('ConfigServiceTopic')
            }
          }
        }
      ]
    )
    Queues [Ref('ConfigServiceQueue')]
  end

  DeliveryChannel('ConfigDeliveryChannel') do
    ConfigSnapshotDeliveryProperties(
      'DeliveryFrequency' => 'Six_Hours'
    )
    S3BucketName Ref('ConfigServiceBucket')
    SnsTopicARN Ref('ConfigServiceTopic')
  end

  ConfigurationRecorder('ConfigRecorder') do
    Name 'DefaultRecorder'
    RecordingGroup(
      'AllSupported' => true
    )
    RoleARN FnGetAtt('ConfigServiceIAMRole', 'Arn')
  end
end
