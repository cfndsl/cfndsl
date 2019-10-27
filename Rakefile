# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cfndsl/version'
require 'rubocop/rake_task'
require 'yamllint/rake_task'
require 'github_changelog_generator/task'
require 'cfndsl/rake_task'

RSpec::Core::RakeTask.new
RuboCop::RakeTask.new

desc 'Run RSpec with SimpleCov'
task :cov do
  ENV['CFNDSL_COV'] = 'true'
  Rake::Task[:spec].execute
end

YamlLint::RakeTask.new do |t|
  t.paths = %w[
    sample/t1.yaml
    .travis.yml
    .rubocop.yml
  ]
end

task default: %i[clean spec rubocop yamllint samples:generate]

# Test our own rake task and samples

directory 'tmp'

namespace :samples do
  source_files = FileList.new('sample/*.rb') { |fl| fl.exclude('**/circular.rb') }

  CfnDsl::RakeTask.new do |t|
    t.specification(file: 'tmp/cloudformation_resources.json')
    desc 'Generate CloudFormation Json'
    t.json(name: :json, files: source_files, pathmap: 'tmp/%f.json', pretty: true, extras: FileList.new('sample/*.yaml'))
    t.yaml(name: :yaml, files: 'sample/t1.rb', pathmap: 'tmp/%f.yaml', extras: '%X.yaml')
  end
end

CLEAN.add 'tmp/*.rb.{json,yaml}', 'tmp/cloudformation_resources.json'

CfnDsl::RakeTask.new do |t|
  desc 'Update Embedded Cloudformation specification'
  t.specification(name: :update_cfn_spec, file: CfnDsl::LOCAL_SPEC_FILE, version: 'latest')
end

# TODO: Bump should ensure we have the latest upstream resource spec
task :bump, :type do |_, args|
  type = args[:type].downcase
  version_path = 'lib/cfndsl/version.rb'
  changelog = 'CHANGELOG.md'

  types = %w[major minor patch]

  raise unless types.include?(type)

  raise "Looks like you're trying to create a release in a branch, you can only create one in 'master'" if `git rev-parse --abbrev-ref HEAD`.strip != 'master'

  version_segments = CfnDsl::VERSION.split('.').map(&:to_i)

  segment_index = types.find_index type

  version_segments = version_segments.take(segment_index) +
                     [version_segments.at(segment_index).succ] +
                     [0] * version_segments.drop(segment_index.succ).count

  version = version_segments.join('.')

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.future_release = version
  end

  puts "Bumping gem from version #{CfnDsl::VERSION} to #{version} as a '#{type.capitalize}' release"

  puts 'Warning, CHANGELOG_GITHUB_TOKEN is unset, you will likely be rate limited' if ENV['CHANGELOG_GITHUB_TOKEN'].nil?
  Rake::Task[:changelog].execute

  contents         = File.read version_path
  updated_contents = contents.gsub(/'[0-9\.]+'/, "'#{version}'")
  File.write(version_path, updated_contents)

  puts 'Commiting version update'
  `git add #{version_path} #{changelog}`
  `git commit --message='#{type.capitalize} release #{version}'`

  puts 'Tagging release'
  `git tag -a v#{version} -m 'Version #{version}'`

  puts 'Pushing branch'
  `git push origin master`

  puts 'Pushing tag'
  `git push origin v#{version}`

  puts 'All done, travis should pick up and release the gem now!'
end
