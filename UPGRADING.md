# Major version upgrades

## 0.x to 1.x

### Deprecations

* FnFormat => FnSub
* addTag => add_tag
* checkRefs => check_refs
* Ruby versions < 2.4
* Legacy cfndsl resource specification files

### Validation

* Tighter validation including for null values and cyclic references in Resources, Outputs, Rules and Conditions
* Tighter definition of duplicates. eg. Route must be EC2_Route because another service now has a Route resource.
* Requires the specification file to exist at the time it is explicitly set with CfnDsl.specification_file=

#### Spec version 

The AWS cloudformation spec will be regularly updated on every release

