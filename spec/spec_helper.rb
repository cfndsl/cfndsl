require 'cfndsl'
require 'aruba/rspec'

bindir = File.expand_path('../../bin', __FILE__)
ENV['PATH'] = [ENV['PATH'], bindir].join(':')

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }
