require 'aruba/rspec'

if ENV['CFNDSL_COV']
  require 'simplecov'

  SimpleCov.start do
    add_group 'Code', 'lib'
    add_group 'test', 'spec'
  end
end

require 'cfndsl'

bindir = File.expand_path('../../bin', __FILE__)
ENV['PATH'] = [ENV['PATH'], bindir].join(':')

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }
