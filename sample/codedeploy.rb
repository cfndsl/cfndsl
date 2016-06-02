CloudFormation do
  DESCRIPTION ||= 'CodeDeploy description'.freeze

  Description DESCRIPTION

  Parameter('ServiceRoleArn') do
    Description 'CodeDeploy Service Role'
    Type 'String'
  end

  Resource('MyCodeDeployApp') do
    Type 'AWS::CodeDeploy::Application'
  end

  Resource('MyDeploymentConfig') do
    Type 'AWS::CodeDeploy::DeploymentConfig'
    Property('MinimumHealthyHosts',
             Type: 'FLEET_PERCENT',
             Value: '50')
  end

  Resource('MyDeploymentGroup') do
    Type 'AWS::CodeDeploy::DeploymentGroup'
    Property('ApplicationName', Ref('MyCodeDeployApp'))
    Property('Deployment',
             Description: 'My App CodeDeploy',
             IgnoreApplicationStopFailures: true,
             Revision: {
               RevisionType: 'S3',
               S3Location: {
                 Bucket: 'my_code_deploy_bucket',
                 Key: '/my_app_code_deloy',
                 BundleType: 'zip',
                 ETag: '1234567890ABCDEF',
                 Version: '10'
               }
             })
    Property('Ec2TagFilters', [{
               Key: 'Role',
               Value: 'myapp',
               Type: 'KEY_AND_VALUE'
             }])
    Property('ServiceRoleArn', Ref('ServiceRoleArn'))
  end
end
