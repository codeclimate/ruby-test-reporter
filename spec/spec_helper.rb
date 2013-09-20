require 'rubygems'
require 'bundler/setup'
require 'artifice'

ENV['CODECLIMATE_REPO_TOKEN'] = "172754c1bf9a3c698f7770b9fb648f1ebb214425120022d0b2ffc65b97dff531"
ENV['CODECLIMATE_API_HOST']   = "http://cc.dev"

class MyRackApp
  def initialize(&block)
    @expection = block
  end
  def call(env)
    @expection.call(env)
    [
      200,
      {"Content-Type" => 'text/plain'},
      ["Received"]
    ]
  end
end


