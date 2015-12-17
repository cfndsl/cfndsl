CloudFormation {
  AWSTemplateFormatVersion "2010-09-09"

  Description "Creates SNS, SQS, S3 bucket and enables AWS Config."

  Queue("ConfigServiceQueue") {
    QueueName "ConfigServiceQueue"
  }

  Bucket("ConfigServiceBucket") {
  }

  Policy("ConfigServiceS3BucketAccessPolicy") {
    PolicyName "ConfigServiceS3BucketAccessPolicy"
    PolicyDocument({
          "Version" => "2012-10-17",
          "Statement" =>
           [
             {
               "Effect" => "Allow",
               "Action" => ["s3:PutObject"],
               "Resource" => FnJoin("", ["arn:aws:s3:::", Ref("ConfigServiceBucket"), "/AWSLogs/" , Ref("AWS::AccountId") , "/*"]),
               "Condition" =>
                {
                  "StringLike" =>
                    {
                      "s3:x-amz-acl" => "bucket-owner-full-control"
                    }
                }
             },
             {
               "Effect" => "Allow",
               "Action" => ["s3:GetBucketAcl"],
               "Resource" => FnJoin("", ["arn:aws:s3:::", Ref("ConfigServiceBucket")])
             }
          ]
        })
    Role Ref("ConfigServiceIAMRole")
  }

  Role("ConfigServiceIAMRole") {
    AssumeRolePolicyDocument({
      "Version" => "2012-10-17",
      "Statement" => [
        {
          "Effect" => "Allow",
          "Principal" => {
            "Service" => "config.amazonaws.com"
          },
          "Action" => "sts:AssumeRole"
        }
      ]
    })
    ManagedPolicyArns([
        "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
    ])
  }

  Topic("ConfigServiceTopic") {
    DisplayName "ConfigSvc"
    Subscription [{
      "Endpoint" => FnGetAtt("ConfigServiceQueue", "Arn"),
      "Protocol" => "sqs"
      }]
  }

  Policy("ConfigServiceSNSTopicAccessPolicy") {
    PolicyName "ConfigServiceSNSTopicAccessPolicy"
    PolicyDocument({
        "Version" => "2012-10-17",
        "Statement" =>
         [
           {
            "Effect" => "Allow",
            "Action" => "sns:Publish",
            "Resource" => Ref("ConfigServiceTopic")
           }
          ]
        })
    Role Ref("ConfigServiceIAMRole")
  }

  QueuePolicy("ConfigServiceQueuePolicy") {
    PolicyDocument({
      "Version" => "2012-10-17",
      "Statement" => [
        {
          "Sid" => "Allow-SendMessage-To-ConfigService-Queue-From-SNS-Topic",
          "Effect" => "Allow",
          "Principal" => "*",
          "Action" => ["sqs:SendMessage"],
          "Resource" => "*",
          "Condition" => {
            "ArnEquals" => {
              "aws:SourceArn" => Ref("ConfigServiceTopic")
            }
          }
        }
      ]
    })
    Queues [ Ref("ConfigServiceQueue") ]
  }

  DeliveryChannel("ConfigDeliveryChannel") {
    ConfigSnapshotDeliveryProperties({
        "DeliveryFrequency" => "Six_Hours"
    })
    S3BucketName Ref("ConfigServiceBucket")
    SnsTopicARN Ref("ConfigServiceTopic")
  }

  ConfigurationRecorder("ConfigRecorder") {
    Name "DefaultRecorder"
    RecordingGroup({
      "AllSupported" => true
    })
    RoleARN FnGetAtt("ConfigServiceIAMRole", "Arn")
  }
}
