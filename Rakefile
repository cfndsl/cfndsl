require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "cfndsl/version"

RSpec::Core::RakeTask.new

task default: [:spec]

task :bump, :type do |t, args|
  type = args[:type].downcase
  version_path = "lib/cfndsl/version.rb"

  fail unless %w(major minor patch).include? type

  if `git rev-parse --abbrev-ref HEAD`.strip != "master"
    fail "Looks like you're trying to create a release in a branch, you can only create one in 'master'"
  end

  version_segments = CfnDsl::VERSION.split(".").map(&:to_i)

  case type
  when "major"
    version_segments[0]+= 1
    version_segments[1] = 0
    version_segments[2] = 0
  when "minor"
    version_segments[1]+= 1
    version_segments[2] = 0
  when "patch"
    version_segments[2]+= 1
  end

  version = version_segments.join(".")

  puts "Bumping gem from version #{CfnDsl::VERSION} to #{version} as a '#{type.capitalize}' release"

  contents         = File.read version_path
  updated_contents = contents.gsub(/([0-9\.]+)/, version)
  File.write(version_path, updated_contents)

  puts "Commiting version update"
  `git add #{version_path}`
  `git commit --message='#{type.capitalize} release #{version}'`

  puts "Tagging release"
  `git tag -a v#{version} -m 'Version #{version}'`

  puts "Pushing branch"
  `git push origin master`

  puts "Pushing tag"
  `git push origin v#{version}`

  puts "All done, travis should pick up and release the gem now!"
end
