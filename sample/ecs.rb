CloudFormation do
  DESCRIPTION ||= 'ecs description'.freeze

  Description DESCRIPTION

  Resource('MyECSCluster') do
    Type 'AWS::ECS::Cluster'
  end

  Resource('MyTaskDef') do
    Type 'AWS::ECS::Service'
    Property('ContainerDefinitions',
             [
               {
                 Command: ['echo hello'],
                 Cpu: 300,
                 EntryPoint: ['/bin/bash'],
                 Environment: [{
                   Name: 'test',
                   Value: 'testvalue'
                 }],
                 Essential: true,
                 Image: 'ubuntu:latest',
                 Links: ['myothercontainer'],
                 Memory: 1024,
                 MountPoints: [{
                   ContainerPath: '/var/log',
                   SourceVolume: 'log_volume',
                   ReadOnly: false
                 }],
                 Name: 'MyTaskDef',
                 PortMappings: [{
                   ContainerPort: 80,
                   HostPort: 8080
                 }],
                 VolumesFrom: [{
                   SourceContainer: 'myothercontainer',
                   ReadOnly: true
                 }]
               }
             ])
  end

  Resource('MyECSService') do
    Type 'AWS::ECS::Service'
    Property('Cluster', Ref('MyECSCluster'))
    Property('DesiredCount', 10)
    Property('Role', 'ecsServiceRole')
    Property('TaskDefinition', 'MyTask:1')
  end
end
