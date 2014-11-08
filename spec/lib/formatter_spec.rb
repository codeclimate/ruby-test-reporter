require 'spec_helper'
require 'fileutils'

module CodeClimate::TestReporter
  describe Formatter do
    let(:project_path) { "spec/tmp" }
    let(:project_file) { "fake_project.rb" }
    let(:formatter) { Formatter.new }
    let(:source_files) {
      double(
        :covered_percent  => 24.3,
        :covered_strength => 33.2,
      )
    }
    let(:files) {
      [
        double(
          :lines            => [double, double, double],
          :covered_lines    => [double, double],
          :missed_lines     => [double],
          :filename         => project_file,
          :coverage         => [0,3,2,nil],
          :covered_percent  => 33.2,
          :covered_strength => 2
        )
      ]
    }

    let(:simplecov_result) {
      double(
        :covered_percent  => 24.3,
        :covered_strength => 33.2,
        :files            => files,
        :source_files     => source_files,
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
      allow(CodeClimate::TestReporter).to receive(:run?).and_return(true)

      app = FakeCodeClimateEndpoint.new
      Artifice.activate_with(app) do
        formatter.format(simplecov_result)
      end

      expect(app.path_info).to eq("/test_reports")
      expect(app.content_type).to eq("application/json")
      expect(app.http_content_encoding).to eq("gzip")

      uncompressed = inflate(app.request_body)

      expected_request.merge!("ci_service" => Ci.service_data)
      expected_json = JSON.parse(expected_request.to_json, symbolize_names: true)

      expect(JSON.parse(uncompressed, symbolize_names: true)).to eq(expected_json)
      expect(app.http_user_agent).to include("v#{CodeClimate::TestReporter::VERSION}")
    end

    describe '#short_filename' do
      it 'should return the filename of the file relative to the SimpleCov root' do
        expect(formatter.short_filename('file1')).to eq('file1')
        expect(formatter.short_filename("#{::SimpleCov.root}/file1")).to eq('file1')
      end

      context "with path prefix" do
        before do
          CodeClimate::TestReporter.configure do |config|
            config.path_prefix = 'custom'
          end
        end

        after do
          CodeClimate::TestReporter.configure do |config|
            config.path_prefix = nil
          end
        end

        it 'should include the path prefix if set' do
          expect(formatter.short_filename('file1')).to eq('custom/file1')
          expect(formatter.short_filename("#{::SimpleCov.root}/file1")).to eq('custom/file1')
        end
      end
    end
  end
end
