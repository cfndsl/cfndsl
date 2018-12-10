# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'hana', '~> 1.3'
gem 'json'

group :development, :test do
  gem 'github_changelog_generator', require: false
  gem 'rubocop', require: false
  gem 'yamllint', require: false
end

group :test do
  gem 'aruba'
  gem 'rake'
  gem 'rspec'
  gem 'simplecov'
end
