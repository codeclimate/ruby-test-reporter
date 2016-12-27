require "simplecov"
SimpleCov.start

require 'bundler/setup'
require 'pry'
require 'codeclimate-test-reporter'
require 'webmock/rspec'

ENV['CODECLIMATE_REPO_TOKEN'] = "172754c1bf9a3c698f7770b9fb648f1ebb214425120022d0b2ffc65b97dff531"
ENV['CODECLIMATE_API_HOST']   = "http://cc.dev"

Dir.glob("spec/support/**/*.rb").sort.each(&method(:load))
