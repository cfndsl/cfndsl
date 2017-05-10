require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cfndsl/version'
require 'rubocop/rake_task'
require 'yamllint/rake_task'
require 'github_changelog_generator/task'

RSpec::Core::RakeTask.new
RuboCop::RakeTask.new

desc 'Run RSpec with SimpleCov'
task :cov do
  ENV['CFNDSL_COV'] = 'true'
  Rake::Task[:spec].execute
end

YamlLint::RakeTask.new do |t|
  t.paths = %w[
    lib/cfndsl/aws/types.yaml
    lib/cfndsl/os/types.yaml
    sample/t1.yaml
    .travis.yml
    .rubocop.yml
  ]
end

task default: %i[spec rubocop yamllint]

GitHubChangelogGenerator::RakeTask.new :changelog

task :bump, :type do |_, args|
  type = args[:type].downcase
  version_path = 'lib/cfndsl/version.rb'
  changelog = 'CHANGELOG.md'

  types = %w[major minor patch]

  raise unless types.include?(type)

  if `git rev-parse --abbrev-ref HEAD`.strip != 'master'
    raise "Looks like you're trying to create a release in a branch, you can only create one in 'master'"
  end

  version_segments = CfnDsl::VERSION.split('.').map(&:to_i)

  segment_index = types.find_index type

  version_segments = version_segments.take(segment_index) +
                     [version_segments.at(segment_index).succ] +
                     [0] * version_segments.drop(segment_index.succ).count

  version = version_segments.join('.')

  puts "Bumping gem from version #{CfnDsl::VERSION} to #{version} as a '#{type.capitalize}' release"

  puts "Warning, CHANGELOG_GITHUB_TOKEN is unset, you will likely be rate limited" if ENV['CHANGELOG_GITHUB_TOKEN'].nil?
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
