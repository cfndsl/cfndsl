CloudFormation {
  DESCRIPTION ||= "ecs description"

  Description DESCRIPTION

  Resource('MyECSCluster') {
    Type 'AWS::ECS::Cluster'
  }

  Resource('MyTaskDef') {
    Type 'AWS::ECS::Service'
    Property('ContainerDefinitions', [
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
  }

  Resource('MyECSService') {
    Type 'AWS::ECS::Service'
    Property('Cluster', Ref('MyECSCluster'))
    Property('DesiredCount', 10)
    Property('Role', 'ecsServiceRole')
    Property('TaskDefinition', 'MyTask:1')
  }
}
