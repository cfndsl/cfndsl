# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cfndsl/version'

Gem::Specification.new do |s|
  s.name          = 'cfndsl'
  s.version       = CfnDsl::VERSION
  s.summary       = 'AWS Cloudformation DSL'
  s.description   = 'DSL for creating AWS Cloudformation templates'
  s.authors       = ['Steven Jack', 'Chris Howe', 'Travis Dempsey']
  s.email         = ['stevenmajack@gmail.com', 'chris@howeville.com', 'dempsey.travis@gmail.com']
  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.homepage      = 'https://github.com/stevenjack/cfndsl'
  s.license       = 'MIT'
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']
  s.bindir        = 'exe'
  s.executables << 'cfndsl'

  s.add_development_dependency 'bundler'
end
