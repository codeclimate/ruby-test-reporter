#!/usr/bin/env ruby

require 'rubygems'
require 'codeclimate-test-reporter'
require 'tmpdir'

if ENV["CODECLIMATE_REPO_TOKEN"]
  tmpdir = "/mnt/tmp/tmp#{ENV['TDDIUM_TID']}"
  puts "Searching #{tmpdir} for files to POST."
  coverage_report_files = Dir.glob("#{tmpdir}/codeclimate-test-coverage-*")
  if coverage_report_files.size > 0
    puts "Found: "
    puts coverage_report_files.join("\n")
    print "Sending reports to #{CodeClimate::TestReporter::API.host}..."
    CodeClimate::TestReporter::API::batch_post(coverage_report_files)
    puts "done."
  else
    puts "No files found to POST."
  end
else
  $stderr.puts "Cannot batch post - environment variable CODECLIMATE_REPO_TOKEN must be set."
  exit(1)
end
