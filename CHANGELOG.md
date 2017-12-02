# Change Log

## [0.16.1](https://github.com/cfndsl/cfndsl/tree/0.16.1) (2017-12-02)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.16.0...0.16.1)

**Closed issues:**

- Metadata / AWS::CloudFormation::Interface support? [\#357](https://github.com/cfndsl/cfndsl/issues/357)

**Merged pull requests:**

- 352 update contacts repos [\#355](https://github.com/cfndsl/cfndsl/pull/355) ([gergnz](https://github.com/gergnz))

## [v0.16.0](https://github.com/cfndsl/cfndsl/tree/v0.16.0) (2017-11-15)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.15.3...v0.16.0)

**Fixed bugs:**

- Rubocop fixes [\#351](https://github.com/cfndsl/cfndsl/pull/351) ([kornypoet](https://github.com/kornypoet))

**Closed issues:**

- How to embed parameter into string? [\#341](https://github.com/cfndsl/cfndsl/issues/341)

**Merged pull requests:**

- cfndsl fix list type subproperties for LaunchSpecifications [\#353](https://github.com/cfndsl/cfndsl/pull/353) ([lwoggardner](https://github.com/lwoggardner))
- Update the embedded resource specification file to version 1.9.1 [\#346](https://github.com/cfndsl/cfndsl/pull/346) ([bobziuchkovski](https://github.com/bobziuchkovski))

## [v0.15.3](https://github.com/cfndsl/cfndsl/tree/v0.15.3) (2017-09-05)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.15.2...v0.15.3)

**Implemented enhancements:**

- list cfndsl equivalents [\#336](https://github.com/cfndsl/cfndsl/issues/336)

**Closed issues:**

- backtrace shown when incorrect resource name is passed to -g [\#338](https://github.com/cfndsl/cfndsl/issues/338)
- Condition and ALB ListenerRule Conditions get merged [\#337](https://github.com/cfndsl/cfndsl/issues/337)
- Request to include support for AWS::Logs::SubscriptionFilter [\#335](https://github.com/cfndsl/cfndsl/issues/335)
- Support for Lambda backed custom resources with shorthand [\#315](https://github.com/cfndsl/cfndsl/issues/315)
- Merging cfnlego, cfn2dsl into cfndsl [\#272](https://github.com/cfndsl/cfndsl/issues/272)

**Merged pull requests:**

- Fix parameter parsing when its value contains equal symbol [\#340](https://github.com/cfndsl/cfndsl/pull/340) ([ans0600](https://github.com/ans0600))

## [v0.15.2](https://github.com/cfndsl/cfndsl/tree/v0.15.2) (2017-06-20)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.15.1...v0.15.2)

**Implemented enhancements:**

- YAML output format in RakeTask [\#300](https://github.com/cfndsl/cfndsl/issues/300)

**Merged pull requests:**

- add outformat for rake task [\#334](https://github.com/cfndsl/cfndsl/pull/334) ([gergnz](https://github.com/gergnz))
- merge ruby version fix into 1.0.0.pre branch [\#333](https://github.com/cfndsl/cfndsl/pull/333) ([gergnz](https://github.com/gergnz))

## [v0.15.1](https://github.com/cfndsl/cfndsl/tree/v0.15.1) (2017-06-19)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.15.0...v0.15.1)

**Fixed bugs:**

- Ruby 2.1.0 is minimum required version, but we don't discuss this anywhere [\#331](https://github.com/cfndsl/cfndsl/issues/331)
- specify ruby v 2.1 as minimum [\#332](https://github.com/cfndsl/cfndsl/pull/332) ([gergnz](https://github.com/gergnz))

## [v0.15.0](https://github.com/cfndsl/cfndsl/tree/v0.15.0) (2017-06-18)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.14.0...v0.15.0)

**Closed issues:**

- Please add support for multiple input files with deep merge [\#327](https://github.com/cfndsl/cfndsl/issues/327)

**Merged pull requests:**

- Clean up of README [\#330](https://github.com/cfndsl/cfndsl/pull/330) ([elmobp](https://github.com/elmobp))
- remove 'disable\_binding', merge 0.x changes [\#329](https://github.com/cfndsl/cfndsl/pull/329) ([gergnz](https://github.com/gergnz))
- enable deep merge as the default for yaml [\#328](https://github.com/cfndsl/cfndsl/pull/328) ([gergnz](https://github.com/gergnz))

## [v0.14.0](https://github.com/cfndsl/cfndsl/tree/v0.14.0) (2017-06-15)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.13.1...v0.14.0)

**Implemented enhancements:**

- Adding support for auto generating cloudformation resources [\#326](https://github.com/cfndsl/cfndsl/pull/326) ([elmobp](https://github.com/elmobp))

**Closed issues:**

- Error reading specification file on 0.13.0 [\#322](https://github.com/cfndsl/cfndsl/issues/322)

**Merged pull requests:**

- Modernize cfndsl executable [\#319](https://github.com/cfndsl/cfndsl/pull/319) ([kornypoet](https://github.com/kornypoet))

## [v0.13.1](https://github.com/cfndsl/cfndsl/tree/v0.13.1) (2017-05-17)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.13.0...v0.13.1)

**Implemented enhancements:**

- Validate against schema used by eclipse plugin [\#49](https://github.com/cfndsl/cfndsl/issues/49)

**Closed issues:**

- Add support for AWS Kinesis Firehose [\#321](https://github.com/cfndsl/cfndsl/issues/321)
- Please add InstanceProfileName property to InstanceProfile resource [\#317](https://github.com/cfndsl/cfndsl/issues/317)

**Merged pull requests:**

- Fallback to included resource spec if not overridden [\#323](https://github.com/cfndsl/cfndsl/pull/323) ([kornypoet](https://github.com/kornypoet))

## [v0.13.0](https://github.com/cfndsl/cfndsl/tree/v0.13.0) (2017-05-17)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.12.11...v0.13.0)

**Closed issues:**

- are there release notes somewhere? [\#299](https://github.com/cfndsl/cfndsl/issues/299)

**Merged pull requests:**

- Remove support for OpenStack Heat [\#318](https://github.com/cfndsl/cfndsl/pull/318) ([kornypoet](https://github.com/kornypoet))
- Remove release\_url config from github changelog generator [\#316](https://github.com/cfndsl/cfndsl/pull/316) ([mikechau](https://github.com/mikechau))
- WIP: Aws schema [\#278](https://github.com/cfndsl/cfndsl/pull/278) ([kornypoet](https://github.com/kornypoet))

## [v0.12.11](https://github.com/cfndsl/cfndsl/tree/v0.12.11) (2017-05-10)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.12.10...v0.12.11)

**Merged pull requests:**

- Add generated changelog [\#314](https://github.com/cfndsl/cfndsl/pull/314) ([mikechau](https://github.com/mikechau))

## [v0.12.10](https://github.com/cfndsl/cfndsl/tree/v0.12.10) (2017-05-10)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.12.9...v0.12.10)

**Merged pull requests:**

- EC2::SecurityGroup: Add GroupName property [\#313](https://github.com/cfndsl/cfndsl/pull/313) ([mikechau](https://github.com/mikechau))

## [v0.12.9](https://github.com/cfndsl/cfndsl/tree/v0.12.9) (2017-05-08)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.12.8...v0.12.9)

**Merged pull requests:**

- Update AWS::CloudWatch::Alarm with 2 new properties [\#312](https://github.com/cfndsl/cfndsl/pull/312) ([AnominousSign](https://github.com/AnominousSign))

## [v0.12.8](https://github.com/cfndsl/cfndsl/tree/v0.12.8) (2017-05-03)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.12.7...v0.12.8)

**Merged pull requests:**

- CloudFormation::Stack: Add Tags property [\#311](https://github.com/cfndsl/cfndsl/pull/311) ([mikechau](https://github.com/mikechau))
- IAM Managed Policy: Add support for ManagedPolicyName property [\#310](https://github.com/cfndsl/cfndsl/pull/310) ([mikechau](https://github.com/mikechau))

## [v0.12.7](https://github.com/cfndsl/cfndsl/tree/v0.12.7) (2017-04-23)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.12.6...v0.12.7)

**Merged pull requests:**

- Add ssm param [\#307](https://github.com/cfndsl/cfndsl/pull/307) ([elmobp](https://github.com/elmobp))

## [v0.12.6](https://github.com/cfndsl/cfndsl/tree/v0.12.6) (2017-04-21)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.12.5...v0.12.6)

**Fixed bugs:**

- AWS::SSM::Parameter support breaks cfndsl [\#308](https://github.com/cfndsl/cfndsl/issues/308)

**Merged pull requests:**

- add a globals class, and exclude reserverd words [\#309](https://github.com/cfndsl/cfndsl/pull/309) ([gergnz](https://github.com/gergnz))

## [v0.12.5](https://github.com/cfndsl/cfndsl/tree/v0.12.5) (2017-04-10)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.12.4...v0.12.5)

**Merged pull requests:**

- Rubocop best practice change for %w literal delimitation [\#306](https://github.com/cfndsl/cfndsl/pull/306) ([AnominousSign](https://github.com/AnominousSign))
- Add Amazon EFS type \(Elastic File System\) [\#305](https://github.com/cfndsl/cfndsl/pull/305) ([AnominousSign](https://github.com/AnominousSign))

## [v0.12.4](https://github.com/cfndsl/cfndsl/tree/v0.12.4) (2017-03-29)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.12.3...v0.12.4)

**Fixed bugs:**

- fixes for rubocop 0.48 [\#302](https://github.com/cfndsl/cfndsl/pull/302) ([gergnz](https://github.com/gergnz))

**Closed issues:**

- Weird output in content section if string given to content doesn't end in new line [\#298](https://github.com/cfndsl/cfndsl/issues/298)
- rake aborted! Seahorse::Client::NetworkingError:execution expired   [\#294](https://github.com/cfndsl/cfndsl/issues/294)

**Merged pull requests:**

- Add SSM Support [\#301](https://github.com/cfndsl/cfndsl/pull/301) ([elmobp](https://github.com/elmobp))

## [v0.12.3](https://github.com/cfndsl/cfndsl/tree/v0.12.3) (2017-03-12)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.12.2...v0.12.3)

**Closed issues:**

- SQS Redrive policy - fix included. [\#295](https://github.com/cfndsl/cfndsl/issues/295)

**Merged pull requests:**

- Fix RedrivePolicy attributes [\#297](https://github.com/cfndsl/cfndsl/pull/297) ([devops-dude](https://github.com/devops-dude))

## [v0.12.2](https://github.com/cfndsl/cfndsl/tree/v0.12.2) (2017-03-04)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.12.1...v0.12.2)

**Closed issues:**

- Rolename is missing from Role [\#291](https://github.com/cfndsl/cfndsl/issues/291)

**Merged pull requests:**

- add UserName property to IAM::User [\#293](https://github.com/cfndsl/cfndsl/pull/293) ([gergnz](https://github.com/gergnz))

## [v0.12.1](https://github.com/cfndsl/cfndsl/tree/v0.12.1) (2017-02-21)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.12.0...v0.12.1)

**Closed issues:**

- Support for Serverless Application Model [\#273](https://github.com/cfndsl/cfndsl/issues/273)

**Merged pull requests:**

- updating IAM::Role and S3::Bucket types [\#292](https://github.com/cfndsl/cfndsl/pull/292) ([kornypoet](https://github.com/kornypoet))

## [v0.12.0](https://github.com/cfndsl/cfndsl/tree/v0.12.0) (2017-01-29)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.11.12...v0.12.0)

**Merged pull requests:**

- Added Serverless::Function & API Transforms [\#290](https://github.com/cfndsl/cfndsl/pull/290) ([jonjitsu](https://github.com/jonjitsu))

## [v0.11.12](https://github.com/cfndsl/cfndsl/tree/v0.11.12) (2017-01-20)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.11.11...v0.11.12)

**Implemented enhancements:**

- Spot fleet support [\#282](https://github.com/cfndsl/cfndsl/issues/282)
- add ipv6 to interfaces [\#284](https://github.com/cfndsl/cfndsl/pull/284) ([gergnz](https://github.com/gergnz))
- Add support for spotfleet. Resolves \#282 [\#283](https://github.com/cfndsl/cfndsl/pull/283) ([gergnz](https://github.com/gergnz))

**Closed issues:**

- Error setting variable with '.' [\#288](https://github.com/cfndsl/cfndsl/issues/288)
- Error specifying an SSL certificate when using an ALB [\#287](https://github.com/cfndsl/cfndsl/issues/287)
- Hyphen in external parameter key throws obscure error  [\#286](https://github.com/cfndsl/cfndsl/issues/286)
- Variable Number of Instances to a LoadBalancer [\#285](https://github.com/cfndsl/cfndsl/issues/285)
- eval\_file\_with\_extras with ":raw" seems like it's trying to do two incompatible things [\#279](https://github.com/cfndsl/cfndsl/issues/279)

**Merged pull requests:**

- Added support for Fn::Split intrinsic function. [\#289](https://github.com/cfndsl/cfndsl/pull/289) ([pablovarela](https://github.com/pablovarela))

## [v0.11.11](https://github.com/cfndsl/cfndsl/tree/v0.11.11) (2016-12-04)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.11.10...v0.11.11)

**Closed issues:**

- Support for environment variables in lambda functions [\#281](https://github.com/cfndsl/cfndsl/issues/281)

**Merged pull requests:**

- Add Environment as a property of Lambda::Function [\#280](https://github.com/cfndsl/cfndsl/pull/280) ([holmesjr](https://github.com/holmesjr))

## [v0.11.10](https://github.com/cfndsl/cfndsl/tree/v0.11.10) (2016-11-23)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.11.9...v0.11.10)

**Closed issues:**

- ApplicationAutoScaling::ScalableTarget not supported. [\#270](https://github.com/cfndsl/cfndsl/issues/270)

**Merged pull requests:**

- Add Autoscaling NotificationConfiguration [\#275](https://github.com/cfndsl/cfndsl/pull/275) ([danielbergamin](https://github.com/danielbergamin))

## [v0.11.9](https://github.com/cfndsl/cfndsl/tree/v0.11.9) (2016-11-18)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.11.8...v0.11.9)

**Closed issues:**

- Metadata in CFN Launch Config [\#268](https://github.com/cfndsl/cfndsl/issues/268)

**Merged pull requests:**

- Application Autoscaling Types [\#271](https://github.com/cfndsl/cfndsl/pull/271) ([kornypoet](https://github.com/kornypoet))

## [v0.11.8](https://github.com/cfndsl/cfndsl/tree/v0.11.8) (2016-11-13)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.11.6...v0.11.8)

**Closed issues:**

- Support for Export/Import values from stacks [\#260](https://github.com/cfndsl/cfndsl/issues/260)

**Merged pull requests:**

- Certificate manager type [\#267](https://github.com/cfndsl/cfndsl/pull/267) ([kornypoet](https://github.com/kornypoet))
- Add monitoring properties to AWS::RDS::DBInstance [\#266](https://github.com/cfndsl/cfndsl/pull/266) ([mikechau](https://github.com/mikechau))
- Add support for AWS::KMS::Alias [\#265](https://github.com/cfndsl/cfndsl/pull/265) ([mikechau](https://github.com/mikechau))

## [v0.11.6](https://github.com/cfndsl/cfndsl/tree/v0.11.6) (2016-10-23)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.11.5...v0.11.6)

**Implemented enhancements:**

- Better test cases [\#16](https://github.com/cfndsl/cfndsl/issues/16)
- Better documentation [\#15](https://github.com/cfndsl/cfndsl/issues/15)

**Fixed bugs:**

- No need to enforce this cop: this is a DSL [\#263](https://github.com/cfndsl/cfndsl/pull/263) ([kornypoet](https://github.com/kornypoet))

**Merged pull requests:**

- Add support for LogGroupName Property [\#262](https://github.com/cfndsl/cfndsl/pull/262) ([mikechau](https://github.com/mikechau))
- Feature/add ecs task definition properties [\#261](https://github.com/cfndsl/cfndsl/pull/261) ([mikechau](https://github.com/mikechau))

## [v0.11.5](https://github.com/cfndsl/cfndsl/tree/v0.11.5) (2016-10-05)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.11.4...v0.11.5)

**Implemented enhancements:**

- Support new function "Sub" [\#241](https://github.com/cfndsl/cfndsl/issues/241)

**Merged pull requests:**

- create fnsub branch, resolves \#244 and \#241 [\#258](https://github.com/cfndsl/cfndsl/pull/258) ([gergnz](https://github.com/gergnz))

## [v0.11.4](https://github.com/cfndsl/cfndsl/tree/v0.11.4) (2016-10-05)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.11.3...v0.11.4)

**Implemented enhancements:**

- Support Import and Export of values for cross stack referencing [\#242](https://github.com/cfndsl/cfndsl/issues/242)
- Support yaml as an output type option [\#240](https://github.com/cfndsl/cfndsl/issues/240)

**Closed issues:**

- Support Cloudformation's new YAML format. [\#254](https://github.com/cfndsl/cfndsl/issues/254)
- Uninitialized constant CfnDsl::VERSION \(NameError\) [\#246](https://github.com/cfndsl/cfndsl/issues/246)

**Merged pull requests:**

- Add ECS ClusterName property to ECS Cluster type. [\#256](https://github.com/cfndsl/cfndsl/pull/256) ([pvdvreede](https://github.com/pvdvreede))
- Update README.md [\#253](https://github.com/cfndsl/cfndsl/pull/253) ([herebebogans](https://github.com/herebebogans))
- Function spec examples [\#251](https://github.com/cfndsl/cfndsl/pull/251) ([kornypoet](https://github.com/kornypoet))
- Initial support for Cross stack references [\#249](https://github.com/cfndsl/cfndsl/pull/249) ([cmaxwellau](https://github.com/cmaxwellau))
- This supports yaml as an output type and leaves json as the default [\#243](https://github.com/cfndsl/cfndsl/pull/243) ([gergnz](https://github.com/gergnz))

## [v0.11.3](https://github.com/cfndsl/cfndsl/tree/v0.11.3) (2016-09-20)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.11.2...v0.11.3)

**Merged pull requests:**

- require cfndsl/version to prevent executable load errors [\#247](https://github.com/cfndsl/cfndsl/pull/247) ([kornypoet](https://github.com/kornypoet))
- Add elastic search version [\#245](https://github.com/cfndsl/cfndsl/pull/245) ([ans0600](https://github.com/ans0600))
- Fix for updated rubocop \(v 0.43.0\) [\#239](https://github.com/cfndsl/cfndsl/pull/239) ([gergnz](https://github.com/gergnz))
- Update conditions.rb [\#238](https://github.com/cfndsl/cfndsl/pull/238) ([herebebogans](https://github.com/herebebogans))

## [v0.11.2](https://github.com/cfndsl/cfndsl/tree/v0.11.2) (2016-09-19)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.11.1...v0.11.2)

**Implemented enhancements:**

- `FnNot` could be improved to not require array as the argument... [\#235](https://github.com/cfndsl/cfndsl/issues/235)
- Provide support for AWS::CloudFormation::CustomResource [\#18](https://github.com/cfndsl/cfndsl/issues/18)
- A couple of little things that were annoying me. [\#237](https://github.com/cfndsl/cfndsl/pull/237) ([gergnz](https://github.com/gergnz))
- Improve FnNot method to not require ruby array. Fixes \#235 [\#236](https://github.com/cfndsl/cfndsl/pull/236) ([gergnz](https://github.com/gergnz))

**Closed issues:**

- DSL to JSON mapping not working [\#230](https://github.com/cfndsl/cfndsl/issues/230)
- undefined method `LoadBalancer' [\#229](https://github.com/cfndsl/cfndsl/issues/229)

**Merged pull requests:**

- Add AccessLoggingPolicy to ELB [\#233](https://github.com/cfndsl/cfndsl/pull/233) ([gergnz](https://github.com/gergnz))

## [v0.11.1](https://github.com/cfndsl/cfndsl/tree/v0.11.1) (2016-09-05)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.11.0...v0.11.1)

**Closed issues:**

- 0.11.0 removal of metadata has caused regression in existing templates [\#227](https://github.com/cfndsl/cfndsl/issues/227)

**Merged pull requests:**

- Add Kinesis Stream to AWS types  [\#228](https://github.com/cfndsl/cfndsl/pull/228) ([holmesjr](https://github.com/holmesjr))
- standardise EC2Tag with ResourceTag [\#225](https://github.com/cfndsl/cfndsl/pull/225) ([gergnz](https://github.com/gergnz))
- Simplecov [\#224](https://github.com/cfndsl/cfndsl/pull/224) ([kornypoet](https://github.com/kornypoet))

## [v0.11.0](https://github.com/cfndsl/cfndsl/tree/v0.11.0) (2016-08-25)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.10.2...v0.11.0)

**Implemented enhancements:**

- Orchestration template spec [\#213](https://github.com/cfndsl/cfndsl/pull/213) ([kornypoet](https://github.com/kornypoet))
- Top Level Metadata [\#209](https://github.com/cfndsl/cfndsl/pull/209) ([kornypoet](https://github.com/kornypoet))

## [v0.10.2](https://github.com/cfndsl/cfndsl/tree/v0.10.2) (2016-08-25)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.10.1...v0.10.2)

**Merged pull requests:**

- Add SsmAssociations to EC2 Instance resource. [\#223](https://github.com/cfndsl/cfndsl/pull/223) ([pvdvreede](https://github.com/pvdvreede))

## [v0.10.1](https://github.com/cfndsl/cfndsl/tree/v0.10.1) (2016-08-24)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.10.0...v0.10.1)

**Merged pull requests:**

- adding elasticache tags [\#216](https://github.com/cfndsl/cfndsl/pull/216) ([jstenhouse](https://github.com/jstenhouse))

## [v0.10.0](https://github.com/cfndsl/cfndsl/tree/v0.10.0) (2016-08-22)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.9.5...v0.10.0)

**Merged pull requests:**

- remove method missing handlers [\#221](https://github.com/cfndsl/cfndsl/pull/221) ([kornypoet](https://github.com/kornypoet))
- adding support for new application load balancers - AWS::ElasticLoadB… [\#220](https://github.com/cfndsl/cfndsl/pull/220) ([jstenhouse](https://github.com/jstenhouse))
- Add GroupName property to IAM Group resource [\#219](https://github.com/cfndsl/cfndsl/pull/219) ([ampedandwired](https://github.com/ampedandwired))
- Add KmsKeyId to the Redshift function. [\#217](https://github.com/cfndsl/cfndsl/pull/217) ([holmesjr](https://github.com/holmesjr))
- Add EC2::FlowLog [\#215](https://github.com/cfndsl/cfndsl/pull/215) ([webdevwilson](https://github.com/webdevwilson))

## [v0.9.5](https://github.com/cfndsl/cfndsl/tree/v0.9.5) (2016-07-26)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.9.4...v0.9.5)

**Implemented enhancements:**

- Plurals spec [\#212](https://github.com/cfndsl/cfndsl/pull/212) ([kornypoet](https://github.com/kornypoet))

## [v0.9.4](https://github.com/cfndsl/cfndsl/tree/v0.9.4) (2016-07-26)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.9.3...v0.9.4)

**Implemented enhancements:**

- Names spec [\#211](https://github.com/cfndsl/cfndsl/pull/211) ([kornypoet](https://github.com/kornypoet))

## [v0.9.3](https://github.com/cfndsl/cfndsl/tree/v0.9.3) (2016-07-26)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.9.2...v0.9.3)

**Merged pull requests:**

- AWS::WAF Type [\#208](https://github.com/cfndsl/cfndsl/pull/208) ([kornypoet](https://github.com/kornypoet))

## [v0.9.2](https://github.com/cfndsl/cfndsl/tree/v0.9.2) (2016-07-06)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.9.1...v0.9.2)

**Fixed bugs:**

- Cfndsl206 apigateway resource [\#207](https://github.com/cfndsl/cfndsl/pull/207) ([gergnz](https://github.com/gergnz))

## [v0.9.1](https://github.com/cfndsl/cfndsl/tree/v0.9.1) (2016-06-22)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.9.0...v0.9.1)

**Implemented enhancements:**

- Remove List context for VpcSettings Datatype [\#204](https://github.com/cfndsl/cfndsl/pull/204) ([herebebogans](https://github.com/herebebogans))
- Add Boolean for UseOpsworksSecurityGroups [\#203](https://github.com/cfndsl/cfndsl/pull/203) ([matthewrkrieger](https://github.com/matthewrkrieger))
- Add RDS Event Subscription cloudformation resource. [\#202](https://github.com/cfndsl/cfndsl/pull/202) ([pvdvreede](https://github.com/pvdvreede))

**Merged pull requests:**

- Api gateway [\#201](https://github.com/cfndsl/cfndsl/pull/201) ([webdevwilson](https://github.com/webdevwilson))

## [v0.9.0](https://github.com/cfndsl/cfndsl/tree/v0.9.0) (2016-06-22)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.8.9...v0.9.0)

**Implemented enhancements:**

- Exparams class methods [\#187](https://github.com/cfndsl/cfndsl/pull/187) ([kornypoet](https://github.com/kornypoet))

## [v0.8.9](https://github.com/cfndsl/cfndsl/tree/v0.8.9) (2016-06-02)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.8.8...v0.8.9)

**Merged pull requests:**

- Add Tags attribute to ELB [\#200](https://github.com/cfndsl/cfndsl/pull/200) ([webdevwilson](https://github.com/webdevwilson))

## [v0.8.8](https://github.com/cfndsl/cfndsl/tree/v0.8.8) (2016-06-02)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.8.7...v0.8.8)

**Merged pull requests:**

- Add AWS RDS Option Group to types. [\#198](https://github.com/cfndsl/cfndsl/pull/198) ([pvdvreede](https://github.com/pvdvreede))

## [v0.8.7](https://github.com/cfndsl/cfndsl/tree/v0.8.7) (2016-06-02)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.8.6...v0.8.7)

**Implemented enhancements:**

- Rubocop 0.40 Fixes [\#195](https://github.com/cfndsl/cfndsl/pull/195) ([gergnz](https://github.com/gergnz))
- Update types.yaml - fixed tenancey typo [\#194](https://github.com/cfndsl/cfndsl/pull/194) ([johnhyland](https://github.com/johnhyland))

## [v0.8.6](https://github.com/cfndsl/cfndsl/tree/v0.8.6) (2016-05-05)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.8.5...v0.8.6)

**Implemented enhancements:**

- Add yamlllint to Gemfile and add a rake task to lint all yaml files. [\#191](https://github.com/cfndsl/cfndsl/pull/191) ([gergnz](https://github.com/gergnz))

**Merged pull requests:**

- Adding MicrosoftAD to AWS types. [\#193](https://github.com/cfndsl/cfndsl/pull/193) ([pvdvreede](https://github.com/pvdvreede))

## [v0.8.5](https://github.com/cfndsl/cfndsl/tree/v0.8.5) (2016-05-04)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.8.4...v0.8.5)

**Implemented enhancements:**

- Build stacks by including other ruby files [\#152](https://github.com/cfndsl/cfndsl/issues/152)
- Osduplicatekey [\#192](https://github.com/cfndsl/cfndsl/pull/192) ([gergnz](https://github.com/gergnz))

**Merged pull requests:**

- Add cloudwatch events type [\#189](https://github.com/cfndsl/cfndsl/pull/189) ([gergnz](https://github.com/gergnz))

## [v0.8.4](https://github.com/cfndsl/cfndsl/tree/v0.8.4) (2016-05-03)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.8.3...v0.8.4)

**Merged pull requests:**

- remove duplicate nat g/w definition [\#190](https://github.com/cfndsl/cfndsl/pull/190) ([gergnz](https://github.com/gergnz))

## [v0.8.3](https://github.com/cfndsl/cfndsl/tree/v0.8.3) (2016-04-27)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.8.2...v0.8.3)

**Fixed bugs:**

- Add tag arguments [\#188](https://github.com/cfndsl/cfndsl/pull/188) ([kornypoet](https://github.com/kornypoet))

## [v0.8.2](https://github.com/cfndsl/cfndsl/tree/v0.8.2) (2016-04-27)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.8.1...v0.8.2)

**Merged pull requests:**

- Updated OpsWorks\_Stack to include ChefConfiguration [\#186](https://github.com/cfndsl/cfndsl/pull/186) ([webdevwilson](https://github.com/webdevwilson))

## [v0.8.1](https://github.com/cfndsl/cfndsl/tree/v0.8.1) (2016-04-27)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.8.0...v0.8.1)

**Merged pull requests:**

- Add in Route53 Health Check Tags as a type [\#185](https://github.com/cfndsl/cfndsl/pull/185) ([gergnz](https://github.com/gergnz))

## [v0.8.0](https://github.com/cfndsl/cfndsl/tree/v0.8.0) (2016-04-27)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.7.0...v0.8.0)

**Implemented enhancements:**

- Use as\_json instead of to\_json [\#157](https://github.com/cfndsl/cfndsl/pull/157) ([johnf](https://github.com/johnf))

**Fixed bugs:**

- Use as\\_json instead of to\\_json [\#157](https://github.com/cfndsl/cfndsl/pull/157) ([johnf](https://github.com/johnf))

## [v0.7.0](https://github.com/cfndsl/cfndsl/tree/v0.7.0) (2016-04-27)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.6.2...v0.7.0)

**Implemented enhancements:**

- Fix the issue with plural types [\#153](https://github.com/cfndsl/cfndsl/pull/153) ([johnf](https://github.com/johnf))

**Fixed bugs:**

- Fix the issue with plural types [\#153](https://github.com/cfndsl/cfndsl/pull/153) ([johnf](https://github.com/johnf))

## [v0.6.2](https://github.com/cfndsl/cfndsl/tree/v0.6.2) (2016-04-19)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.6.1...v0.6.2)

**Implemented enhancements:**

- Fix for \#181 - deprecation warning [\#182](https://github.com/cfndsl/cfndsl/pull/182) ([cmaxwellau](https://github.com/cmaxwellau))

**Fixed bugs:**

- Fix for \\#181 - deprecation warning [\#182](https://github.com/cfndsl/cfndsl/pull/182) ([cmaxwellau](https://github.com/cmaxwellau))

**Closed issues:**

- Deprecation warning with rake 11.1.2 [\#181](https://github.com/cfndsl/cfndsl/issues/181)

## [v0.6.1](https://github.com/cfndsl/cfndsl/tree/v0.6.1) (2016-04-18)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.6.0...v0.6.1)

**Implemented enhancements:**

- External Parameters [\#170](https://github.com/cfndsl/cfndsl/issues/170)

**Merged pull requests:**

- Update types.yaml [\#180](https://github.com/cfndsl/cfndsl/pull/180) ([herebebogans](https://github.com/herebebogans))

## [v0.6.0](https://github.com/cfndsl/cfndsl/tree/v0.6.0) (2016-04-18)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.5.2...v0.6.0)

**Implemented enhancements:**

- External params [\#179](https://github.com/cfndsl/cfndsl/pull/179) ([kornypoet](https://github.com/kornypoet))

## [v0.5.2](https://github.com/cfndsl/cfndsl/tree/v0.5.2) (2016-04-15)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.5.1...v0.5.2)

**Fixed bugs:**

- 5.0 release breaks addTag  [\#175](https://github.com/cfndsl/cfndsl/issues/175)
- Remove erroneous logstream output [\#178](https://github.com/cfndsl/cfndsl/pull/178) ([stevenjack](https://github.com/stevenjack))

## [v0.5.1](https://github.com/cfndsl/cfndsl/tree/v0.5.1) (2016-04-15)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.5.0...v0.5.1)

**Implemented enhancements:**

- Fix Rake task for bumping version number [\#173](https://github.com/cfndsl/cfndsl/pull/173) ([stevenjack](https://github.com/stevenjack))

**Fixed bugs:**

- JSON pretty printing for rake generated cloudformation [\#177](https://github.com/cfndsl/cfndsl/pull/177) ([cmaxwellau](https://github.com/cmaxwellau))

**Closed issues:**

- Pretty printing no longer working with Rake builds [\#176](https://github.com/cfndsl/cfndsl/issues/176)

## [v0.5.0](https://github.com/cfndsl/cfndsl/tree/v0.5.0) (2016-04-13)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.4.4...v0.5.0)

**Implemented enhancements:**

- Code cleanup and improvments - Help needed [\#171](https://github.com/cfndsl/cfndsl/issues/171)
- cfndsl\_examples [\#83](https://github.com/cfndsl/cfndsl/issues/83)
- The Juno release of Openstack Heat has a whole new floatilla of resources [\#67](https://github.com/cfndsl/cfndsl/issues/67)
- CLI Tests [\#169](https://github.com/cfndsl/cfndsl/pull/169) ([kornypoet](https://github.com/kornypoet))
- Rubocop fixes [\#161](https://github.com/cfndsl/cfndsl/pull/161) ([stevenjack](https://github.com/stevenjack))

## [v0.4.4](https://github.com/cfndsl/cfndsl/tree/v0.4.4) (2016-04-01)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.4.2...v0.4.4)

**Closed issues:**

- Updating aws\_types.yaml? [\#165](https://github.com/cfndsl/cfndsl/issues/165)

## [v0.4.2](https://github.com/cfndsl/cfndsl/tree/v0.4.2) (2016-03-03)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.4.3...v0.4.2)

## [v0.4.3](https://github.com/cfndsl/cfndsl/tree/v0.4.3) (2016-03-01)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.4.1...v0.4.3)

**Closed issues:**

- Support the Elasticsearch Service [\#155](https://github.com/cfndsl/cfndsl/issues/155)

## [v0.4.1](https://github.com/cfndsl/cfndsl/tree/v0.4.1) (2016-02-18)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.4.0...v0.4.1)

## [v0.4.0](https://github.com/cfndsl/cfndsl/tree/v0.4.0) (2016-02-11)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.3.6...v0.4.0)

## [v0.3.6](https://github.com/cfndsl/cfndsl/tree/v0.3.6) (2016-02-09)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.3.5...v0.3.6)

**Implemented enhancements:**

- Pretty-formatted multi-line output JSON [\#149](https://github.com/cfndsl/cfndsl/issues/149)

## [v0.3.5](https://github.com/cfndsl/cfndsl/tree/v0.3.5) (2016-02-03)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.3.4...v0.3.5)

## [v0.3.4](https://github.com/cfndsl/cfndsl/tree/v0.3.4) (2016-01-28)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.3.3...v0.3.4)

**Merged pull requests:**

- add AutoScalingConfiguration missing property [\#144](https://github.com/cfndsl/cfndsl/pull/144) ([kornypoet](https://github.com/kornypoet))

## [v0.3.3](https://github.com/cfndsl/cfndsl/tree/v0.3.3) (2015-12-26)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.3.2...v0.3.3)

**Closed issues:**

- Add support for additional RDS properties [\#142](https://github.com/cfndsl/cfndsl/issues/142)
- Add support for KMS::Key [\#140](https://github.com/cfndsl/cfndsl/issues/140)

## [v0.3.2](https://github.com/cfndsl/cfndsl/tree/v0.3.2) (2015-11-20)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.3.1...v0.3.2)

**Merged pull requests:**

- json gem required [\#136](https://github.com/cfndsl/cfndsl/pull/136) ([erikmack](https://github.com/erikmack))
- Ensure last value wins when a Property is set multiple times [\#135](https://github.com/cfndsl/cfndsl/pull/135) ([erikmack](https://github.com/erikmack))
- Fix typo in return type [\#134](https://github.com/cfndsl/cfndsl/pull/134) ([erikmack](https://github.com/erikmack))
- Update t1.rb template to match README text [\#132](https://github.com/cfndsl/cfndsl/pull/132) ([nickjwebb](https://github.com/nickjwebb))
- Enable NotificationConfigurations on S3 Bucket object [\#131](https://github.com/cfndsl/cfndsl/pull/131) ([webdevwilson](https://github.com/webdevwilson))

## [v0.3.1](https://github.com/cfndsl/cfndsl/tree/v0.3.1) (2015-10-29)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.2.9...v0.3.1)

## [v0.2.9](https://github.com/cfndsl/cfndsl/tree/v0.2.9) (2015-10-29)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.2.8...v0.2.9)

## [v0.2.8](https://github.com/cfndsl/cfndsl/tree/v0.2.8) (2015-10-29)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.2.7...v0.2.8)

## [v0.2.7](https://github.com/cfndsl/cfndsl/tree/v0.2.7) (2015-10-14)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.2.4...v0.2.7)

## [v0.2.4](https://github.com/cfndsl/cfndsl/tree/v0.2.4) (2015-09-29)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.3.0...v0.2.4)

## [v0.3.0](https://github.com/cfndsl/cfndsl/tree/v0.3.0) (2015-09-29)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.2.3...v0.3.0)

## [v0.2.3](https://github.com/cfndsl/cfndsl/tree/v0.2.3) (2015-08-26)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.2.2...v0.2.3)

**Closed issues:**

- Undefined symbol: EC2MountPoint - possible issue? [\#124](https://github.com/cfndsl/cfndsl/issues/124)

## [v0.2.2](https://github.com/cfndsl/cfndsl/tree/v0.2.2) (2015-08-10)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.2.1...v0.2.2)

## [v0.2.1](https://github.com/cfndsl/cfndsl/tree/v0.2.1) (2015-08-10)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.2.0...v0.2.1)

## [v0.2.0](https://github.com/cfndsl/cfndsl/tree/v0.2.0) (2015-08-10)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.20...v0.2.0)

**Closed issues:**

- Add support for IAM::Group ManagedPolicyArns [\#119](https://github.com/cfndsl/cfndsl/issues/119)

## [v0.1.20](https://github.com/cfndsl/cfndsl/tree/v0.1.20) (2015-07-22)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.19...v0.1.20)

**Closed issues:**

- Add support for IAM::Role ManagedPolicyArns [\#114](https://github.com/cfndsl/cfndsl/issues/114)
- aws\_types.aws AWS::SQS::Queue missing property QueueName: String [\#108](https://github.com/cfndsl/cfndsl/issues/108)

## [v0.1.19](https://github.com/cfndsl/cfndsl/tree/v0.1.19) (2015-07-16)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.18...v0.1.19)

**Closed issues:**

- SecurityGroupIngress/Egress formatting with additional \[\] [\#109](https://github.com/cfndsl/cfndsl/issues/109)

## [v0.1.18](https://github.com/cfndsl/cfndsl/tree/v0.1.18) (2015-06-22)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.17...v0.1.18)

## [v0.1.17](https://github.com/cfndsl/cfndsl/tree/v0.1.17) (2015-06-22)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.16...v0.1.17)

## [v0.1.16](https://github.com/cfndsl/cfndsl/tree/v0.1.16) (2015-06-15)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.15...v0.1.16)

**Fixed bugs:**

- PreferredAvailabilityZone Property on ElastiCache\_CacheCluster is incorrect [\#92](https://github.com/cfndsl/cfndsl/issues/92)

## [v0.1.15](https://github.com/cfndsl/cfndsl/tree/v0.1.15) (2015-05-10)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.14...v0.1.15)

**Closed issues:**

- Oddity where do/end block breaks expectations, but {} works fine? [\#86](https://github.com/cfndsl/cfndsl/issues/86)

## [v0.1.14](https://github.com/cfndsl/cfndsl/tree/v0.1.14) (2015-04-24)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.11...v0.1.14)

**Implemented enhancements:**

- Alert user if they've incorrectly capitialized the function name [\#84](https://github.com/cfndsl/cfndsl/pull/84) ([stevenjack](https://github.com/stevenjack))

**Merged pull requests:**

- Redshift [\#87](https://github.com/cfndsl/cfndsl/pull/87) ([kornypoet](https://github.com/kornypoet))
- Add Route53::HostedZone and Route53::HealthCheck [\#85](https://github.com/cfndsl/cfndsl/pull/85) ([benley](https://github.com/benley))

## [v0.1.11](https://github.com/cfndsl/cfndsl/tree/v0.1.11) (2015-02-05)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.10...v0.1.11)

**Implemented enhancements:**

- "AWS::SNS::Topic" does not appear to be fully defined [\#81](https://github.com/cfndsl/cfndsl/issues/81)

## [v0.1.10](https://github.com/cfndsl/cfndsl/tree/v0.1.10) (2015-01-19)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.9...v0.1.10)

## [v0.1.9](https://github.com/cfndsl/cfndsl/tree/v0.1.9) (2015-01-13)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.8...v0.1.9)

**Closed issues:**

- Add some better support for base64 in FnFormat [\#66](https://github.com/cfndsl/cfndsl/issues/66)

**Merged pull requests:**

- Fixes a typo in cfndsl.rb that was causing an error when in verbose mode... [\#76](https://github.com/cfndsl/cfndsl/pull/76) ([scottabutler](https://github.com/scottabutler))

## [v0.1.8](https://github.com/cfndsl/cfndsl/tree/v0.1.8) (2015-01-02)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.7...v0.1.8)

## [v0.1.7](https://github.com/cfndsl/cfndsl/tree/v0.1.7) (2014-12-26)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.3...v0.1.7)

**Closed issues:**

- Support for userData Script [\#57](https://github.com/cfndsl/cfndsl/issues/57)
- The AWS Resource AWS::EC2::NetworkInterface is missing [\#54](https://github.com/cfndsl/cfndsl/issues/54)
- Add support for Openstack Heat [\#33](https://github.com/cfndsl/cfndsl/issues/33)
- Self-referencing SecurityGroups [\#32](https://github.com/cfndsl/cfndsl/issues/32)
- CloudFormation output ordering doesn't match order of cfndsl template [\#26](https://github.com/cfndsl/cfndsl/issues/26)
- Limited Validatation of Resource Property Data Types [\#4](https://github.com/cfndsl/cfndsl/issues/4)

**Merged pull requests:**

- typo [\#69](https://github.com/cfndsl/cfndsl/pull/69) ([tbenade](https://github.com/tbenade))
- Add support for OpsWorks types [\#64](https://github.com/cfndsl/cfndsl/pull/64) ([benley](https://github.com/benley))
- Made some changes to aws\_types.yaml to try to keep up with changes made ... [\#62](https://github.com/cfndsl/cfndsl/pull/62) ([howech](https://github.com/howech))
- Add support for ConnectionDrainingPolicy [\#61](https://github.com/cfndsl/cfndsl/pull/61) ([josephglanville](https://github.com/josephglanville))
- Add some missing properties of numerous resources [\#60](https://github.com/cfndsl/cfndsl/pull/60) ([josephglanville](https://github.com/josephglanville))
- Added some command line options to affect the behavior of cfndsl. [\#59](https://github.com/cfndsl/cfndsl/pull/59) ([howech](https://github.com/howech))
- Add some nominal support for Openstack Heat [\#58](https://github.com/cfndsl/cfndsl/pull/58) ([howech](https://github.com/howech))
- Eval context [\#56](https://github.com/cfndsl/cfndsl/pull/56) ([howech](https://github.com/howech))
- Add NetworkInterface resource Closes \#54 [\#55](https://github.com/cfndsl/cfndsl/pull/55) ([erikmack](https://github.com/erikmack))

## [v0.1.3](https://github.com/cfndsl/cfndsl/tree/v0.1.3) (2014-07-02)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.2...v0.1.3)

**Fixed bugs:**

- fixed a typo in SourceSecurityGroupName and SourceSecurityGroupId [\#51](https://github.com/cfndsl/cfndsl/pull/51) ([howech](https://github.com/howech))

**Closed issues:**

- Output to a string instead of STDOUT? [\#23](https://github.com/cfndsl/cfndsl/issues/23)

## [v0.1.2](https://github.com/cfndsl/cfndsl/tree/v0.1.2) (2014-05-28)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.1...v0.1.2)

**Closed issues:**

- Publish Updated Gem? [\#50](https://github.com/cfndsl/cfndsl/issues/50)

## [v0.1.1](https://github.com/cfndsl/cfndsl/tree/v0.1.1) (2014-05-14)
[Full Changelog](https://github.com/cfndsl/cfndsl/compare/v0.1.0...v0.1.1)

**Closed issues:**

- License missing from gemspec [\#21](https://github.com/cfndsl/cfndsl/issues/21)

**Merged pull requests:**

- Change license to MIT and update gemfile [\#48](https://github.com/cfndsl/cfndsl/pull/48) ([stevenjack](https://github.com/stevenjack))

## [v0.1.0](https://github.com/cfndsl/cfndsl/tree/v0.1.0) (2014-05-13)
**Implemented enhancements:**

- Adds missing Pseudo Parameters [\#40](https://github.com/cfndsl/cfndsl/pull/40) ([stevenjack](https://github.com/stevenjack))
- ASG update policy [\#38](https://github.com/cfndsl/cfndsl/pull/38) ([k-ong](https://github.com/k-ong))
- Added FnSelect function to JSONable.rb [\#36](https://github.com/cfndsl/cfndsl/pull/36) ([louism517](https://github.com/louism517))
- Adding new properties to various resources [\#35](https://github.com/cfndsl/cfndsl/pull/35) ([ianneub](https://github.com/ianneub))

**Closed issues:**

- Add support for UpdatePolicy on AutoScalingGroups [\#34](https://github.com/cfndsl/cfndsl/issues/34)
- One cfndsl file =\> multiple Cloudformation templates [\#29](https://github.com/cfndsl/cfndsl/issues/29)
- Errors on Mac 10.8.4, using version installed with 'gem install cfndsl' [\#25](https://github.com/cfndsl/cfndsl/issues/25)
- Requesting cfndsl example based on this AWS example template [\#24](https://github.com/cfndsl/cfndsl/issues/24)
- Feature Request: Support for "AWS::CloudFormation::Init" and "AWS::CloudFormation::Authentication" Types [\#17](https://github.com/cfndsl/cfndsl/issues/17)
- Unify implementations of singular/plural methods for array properties [\#13](https://github.com/cfndsl/cfndsl/issues/13)
- Better way to tag Instances [\#11](https://github.com/cfndsl/cfndsl/issues/11)
- Format identifiers [\#9](https://github.com/cfndsl/cfndsl/issues/9)
- Add Properties syntax for Resources [\#8](https://github.com/cfndsl/cfndsl/issues/8)
- Set up the cfn-init metadata to work like resources [\#7](https://github.com/cfndsl/cfndsl/issues/7)
- Better Error Handling via method\_missing [\#6](https://github.com/cfndsl/cfndsl/issues/6)
- Data driven type specifier [\#5](https://github.com/cfndsl/cfndsl/issues/5)
- Validate Resource Property Names [\#3](https://github.com/cfndsl/cfndsl/issues/3)
- Validate Resource Types [\#2](https://github.com/cfndsl/cfndsl/issues/2)

**Merged pull requests:**

- Updates test script to use correct load balancer names property [\#47](https://github.com/cfndsl/cfndsl/pull/47) ([stevenjack](https://github.com/stevenjack))
- Adds bundler tasks to ease testing gem and releasing [\#46](https://github.com/cfndsl/cfndsl/pull/46) ([stevenjack](https://github.com/stevenjack))
- Asg update policy [\#45](https://github.com/cfndsl/cfndsl/pull/45) ([stevenjack](https://github.com/stevenjack))
- Add conditions [\#44](https://github.com/cfndsl/cfndsl/pull/44) ([stevenjack](https://github.com/stevenjack))
- Don't exit - write error to STDERR [\#43](https://github.com/cfndsl/cfndsl/pull/43) ([stevenjack](https://github.com/stevenjack))
- Travis integration [\#42](https://github.com/cfndsl/cfndsl/pull/42) ([stevenjack](https://github.com/stevenjack))
- Corrected GetAtt typo. Edit doesn't appear to alter output. [\#31](https://github.com/cfndsl/cfndsl/pull/31) ([josh-wrale](https://github.com/josh-wrale))
- Fixed incomplete 'GroupName' property for AWS::IAM::UserToGroupAddition [\#30](https://github.com/cfndsl/cfndsl/pull/30) ([josh-wrale](https://github.com/josh-wrale))
- IAM Additions and Small Corrections and/or Improvements [\#28](https://github.com/cfndsl/cfndsl/pull/28) ([josh-wrale](https://github.com/josh-wrale))
- Added IamInstanceProfile to EC2::Instance type. [\#27](https://github.com/cfndsl/cfndsl/pull/27) ([ianneub](https://github.com/ianneub))
- Changing AliasTarget property to be a single AliasTarget, and not an array of them. [\#22](https://github.com/cfndsl/cfndsl/pull/22) ([ianneub](https://github.com/ianneub))
- Clean up the Listener property type [\#20](https://github.com/cfndsl/cfndsl/pull/20) ([ianneub](https://github.com/ianneub))
- Reimplmenented property methods as outlined in issue \#13 [\#14](https://github.com/cfndsl/cfndsl/pull/14) ([howech](https://github.com/howech))
- Added resources definitions related to VPC [\#12](https://github.com/cfndsl/cfndsl/pull/12) ([liguorien](https://github.com/liguorien))
- Added a Tag function [\#10](https://github.com/cfndsl/cfndsl/pull/10) ([liguorien](https://github.com/liguorien))
- Update supported pseudo parameters [\#1](https://github.com/cfndsl/cfndsl/pull/1) ([radim](https://github.com/radim))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*