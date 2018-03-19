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
  s.required_ruby_version = '~> 2.1'

  s.executables << 'cfndsl'

  s.add_development_dependency 'bundler', '~> 1.13'

  s.post_install_message = "'addTag' is now deprecated in favour of 'add_tag'. 'addTag' will be removed in the next major version."
end
