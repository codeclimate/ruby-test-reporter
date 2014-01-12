require 'spec_helper'
require 'fileutils'

module CodeClimate::TestReporter
  describe Formatter do
    let(:project_path) { "spec/tmp" }
    let(:project_file) { "fake_project.rb" }
    let(:formatter) { Formatter.new }
    let(:files) {
      [
        mock(
          :lines            => [mock, mock, mock],
          :covered_lines    => [mock, mock],
          :missed_lines     => [mock],
          :filename         => project_file,
          :coverage         => [0,3,2,nil],
          :covered_percent  => 33.2,
          :covered_strength => 2
        )
      ]
    }

    let(:simplecov_result) {
      mock(
        :covered_percent  => 24.3,
        :covered_strength => 33.2,
        :files            => files,
        :created_at       => Time.at(1379704336),
        :command_name     => "rspec"
      )
    }

    let(:expected_request) {
      {
        "repo_token" => "172754c1bf9a3c698f7770b9fb648f1ebb214425120022d0b2ffc65b97dff531",
        "source_files" =>
          [
            {
              "name" => project_file,
              "blob_id" => "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",
              "coverage" => "[0,3,2,null]",
              "covered_percent" => 33.2,
              "covered_strength" => 2.0,
              "line_counts" => {"total"=>3, "covered"=>2, "missed"=>1}
            }
          ],
        "run_at" => 1379704336,
        "covered_percent" => 24.3,
        "covered_strength" => 33.2,
        "line_counts" => {"total" => 3, "covered" => 2, "missed" => 1 },
        "partial"=> false,
        "git" =>
          {
            "head" => @commit_sha,
            "committed_at" => @committed_at.to_i,
            "branch" => "master"
          },
        "environment" =>
          {
            "test_framework" => "rspec",
            "pwd" => Dir.pwd,
            "rails_root" => nil,
            "simplecov_root" => Dir.pwd,
            "gem_version" => VERSION
          },
        "ci_service" => {}
      }
    }

    before do
      @old_pwd = Dir.pwd
      FileUtils.mkdir_p(project_path)
      FileUtils.cd(project_path)
      FileUtils.touch(project_file)
      SimpleCov.root(Dir.pwd)
      system("git init")
      system("git add #{project_file}")
      system("git commit -m 'initial commit'")
      @commit_sha = `git log -1 --pretty=format:'%H'`
      @committed_at = `git log -1 --pretty=format:'%ct'`
    end

    after do
      FileUtils.cd(@old_pwd)
      FileUtils.rm_rf(project_path)
    end

    it "sends an http request with all the coverage information" do
      app = FakeCodeClimateEndpoint.new
      Artifice.activate_with(app) do
        formatter.format(simplecov_result)
      end
      app.path_info.should == "/test_reports"
      app.content_type.should == "application/json"
      app.http_content_encoding.should == "gzip"
      uncompressed = inflate(app.request_body)
      JSON.parse(uncompressed).should == expected_request
      app.http_user_agent.should include("v#{CodeClimate::TestReporter::VERSION}")
    end
  end

  describe '#short_filename' do
    it 'should return the filename of the file relative to the SimpleCov root' do
      CodeClimate::TestReporter::Formatter.new.short_filename('file1').should == 'file1'
      CodeClimate::TestReporter::Formatter.new.short_filename("#{::SimpleCov.root}/file1").should == 'file1'
    end

    it 'should include the path prefix if set' do
      CodeClimate::TestReporter.configure do |config|
        config.path_prefix = 'custom'
      end
      CodeClimate::TestReporter::Formatter.new.short_filename('file1').should == 'custom/file1'
      CodeClimate::TestReporter::Formatter.new.short_filename("#{::SimpleCov.root}/file1").should == 'custom/file1'
      CodeClimate::TestReporter.configure do |config|
        config.path_prefix = nil
      end
    end
  end
end
