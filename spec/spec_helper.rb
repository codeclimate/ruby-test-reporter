require "simplecov"
SimpleCov.start

require 'bundler/setup'
require 'pry'
require 'codeclimate-test-reporter'
require 'webmock/rspec'

ENV['CODECLIMATE_REPO_TOKEN'] = "172754c1bf9a3c698f7770b9fb648f1ebb214425120022d0b2ffc65b97dff531"
ENV['CODECLIMATE_API_HOST']   = "http://cc.dev"

module TestHelper
  def inflate(string)
    reader = Zlib::GzipReader.new(StringIO.new(string))
    reader.read
  end

  def capture_requests(stub)
    requests = []
    stub.to_return { |r| requests << r; {body: "hello"} }
    requests
  end
end

RSpec.configure do |c|
  c.include TestHelper
end


