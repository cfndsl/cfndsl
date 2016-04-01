require 'cfndsl'
require 'aruba/rspec'

bindir = File.expand_path('../../bin', __FILE__)
ENV['PATH'] = [ENV['PATH'], bindir].join(':')
