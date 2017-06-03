# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cfndsl/version'

Gem::Specification.new do |s|
  s.name          = 'cfndsl'
  s.version       = CfnDsl::VERSION
  s.summary       = 'AWS Cloudformation DSL'
  s.description   = 'DSL for creating AWS Cloudformation templates'
  s.authors       = ['Steven Jack', 'Chris Howe']
  s.email         = ['stevenmajack@gmail.com', 'chris@howeville.com']
  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.homepage      = 'https://github.com/stevenjack/cfndsl'
  s.license       = 'MIT'
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.executables << 'cfndsl'

  s.add_development_dependency 'bundler'

  s.post_install_message = "'addTag' is now deprecated in favour of 'add_tag'. 'addTag' will be removed in the next major version."
end
