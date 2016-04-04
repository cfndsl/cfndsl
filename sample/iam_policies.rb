CloudFormation do
  AWSTemplateFormatVersion '2010-09-09'

  Description 'Creates sample IAM policies'

  ManagedPolicy('AllowUserManagePasswordAccessKeys') do
    Description 'Allows user to manage passwords and access keys'
    PolicyDocument(
      'Version' => '2012-10-17',
      'Statement' => [
        {
          'Effect' => 'Allow',
          'Action' => [
            'iam:*LoginProfile',
            'iam:*AccessKey*',
            'iam:*SSHPublicKey*'
          ],
          'Resource' => FnJoin('', ['arn:aws:iam::', Ref('AWS::AccountId'), ':user/${aws:username}'])
        }
      ]
    )
  end

  ManagedPolicy('AllowUserManageVirtualMFA') do
    Description 'Allows user to manage their virtual MFA device'
    PolicyDocument(
      'Version' => '2012-10-17',
      'Statement' => [
        {
          'Sid' => 'AllowUsersToCreateEnableResyncTheirOwnVirtualMFADevice',
          'Effect' => 'Allow',
          'Action' => [
            'iam:CreateVirtualMFADevice',
            'iam:EnableMFADevice',
            'iam:ResyncMFADevice'
          ],
          'Resource' => [
            FnJoin('', ['arn:aws:iam::', Ref('AWS::AccountId'), ':mfa/${aws:username}']),
            FnJoin('', ['arn:aws:iam::', Ref('AWS::AccountId'), ':user/${aws:username}'])
          ]
        },
        {
          'Sid' => 'AllowUsersToDeactivateDeleteTheirOwnVirtualMFADevice',
          'Effect' => 'Allow',
          'Action' => [
            'iam:DeactivateMFADevice',
            'iam:DeleteVirtualMFADevice'
          ],
          'Resource' => [
            FnJoin('', ['arn:aws:iam::', Ref('AWS::AccountId'), ':mfa/${aws:username}']),
            FnJoin('', ['arn:aws:iam::', Ref('AWS::AccountId'), ':user/${aws:username}'])
          ],
          'Condition' => {
            'Bool' => {
              'aws:MultiFactorAuthPresent' => true
            }
          }
        },
        {
          'Sid' => 'AllowUsersToListMFADevicesandUsersForConsole',
          'Effect' => 'Allow',
          'Action' => [
            'iam:ListMFADevices',
            'iam:ListVirtualMFADevices',
            'iam:ListUsers'
          ],
          'Resource' => '*'
        }
      ]
    )
  end

  Output('AllowUserManagePasswordAccessKeysPolicyArn') do
    Description 'The ARN of the AllowUserManagePasswordAccessKeys IAM policy'
    Value Ref('AllowUserManagePasswordAccessKeys')
  end

  Output('AllowUserManageVirtualMFAPolicyArn') do
    Description 'The ARN of the AllowUserManageVirtualMFA IAM policy'
    Value Ref('AllowUserManageVirtualMFA')
  end
end
