require 'rubygems'
require 'bundler/setup'
require 'artifice'
require 'pry'

ENV['CODECLIMATE_REPO_TOKEN'] = "172754c1bf9a3c698f7770b9fb648f1ebb214425120022d0b2ffc65b97dff531"
ENV['CODECLIMATE_API_HOST']   = "http://cc.dev"

class FakeCodeClimateEndpoint
  def call(env)
    @env = env
    [
      200,
      {"Content-Type" => 'text/plain'},
      ["Received"]
    ]
  end

  def path_info
    @env["PATH_INFO"]
  end

  def request_body
    @env["rack.input"].string
  end

  def content_type
    @env["CONTENT_TYPE"]
  end

  def query_string
    @env["QUERY_STRING"]
  end
end


