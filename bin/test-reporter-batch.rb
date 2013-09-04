#!/usr/bin/env ruby

require 'rubygems'
require 'codeclimate-test-reporter'
require 'tmpdir'

if ENV["CODECLIMATE_REPO_TOKEN"]
  coverage_report_files = Dir.glob("#{Dir.tmpdir}/codeclimate-test-coverage-*")
  CodeClimate::TestReporter::API::batch_post(coverage_report_files)
else
  $stderr.puts "Cannot batch post - environment variable CODECLIMATE_REPO_TOKEN must be set."
  exit(1)
end
