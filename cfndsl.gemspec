# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cfndsl/version'

Gem::Specification.new do |s|
  s.name                  = 'cfndsl'
  s.version               = CfnDsl::VERSION
  s.summary               = 'AWS Cloudformation DSL'
  s.description           = 'DSL for creating AWS Cloudformation templates'
  s.authors               = ['Steven Jack', 'Chris Howe', 'Travis Dempsey', 'Greg Cockburn']
  s.email                 = ['stevenmajack@gmail.com', 'chris@howeville.com', 'dempsey.travis@gmail.com', 'gergnz@gmail.com']
  s.files                 = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.homepage              = 'https://github.com/cfndsl/cfndsl'
  s.license               = 'MIT'
  s.test_files            = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths         = ['lib']
  s.bindir                = 'exe'
  s.required_ruby_version = '~> 2.3'

  s.executables << 'cfndsl'

  s.add_development_dependency 'bundler', '~> 1.17'
  s.add_runtime_dependency 'hana', '~> 1.3'
end
