require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cfndsl/version'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new
RuboCop::RakeTask.new

task default: [:spec, :rubocop]

task :bump, :type do |_, args|
  type = args[:type].downcase
  version_path = 'lib/cfndsl/version.rb'

  types = %w(major minor patch)

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

  contents         = File.read version_path
  updated_contents = contents.gsub(/([0-9\.]+)/, version)
  File.write(version_path, updated_contents)

  puts 'Commiting version update'
  `git add #{version_path}`
  `git commit --message='#{type.capitalize} release #{version}'`

  puts 'Tagging release'
  `git tag -a v#{version} -m 'Version #{version}'`

  puts 'Pushing branch'
  `git push origin master`

  puts 'Pushing tag'
  `git push origin v#{version}`

  puts 'All done, travis should pick up and release the gem now!'
end
