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
          :skipped_lines    => [double(:line_number => 5), double(:line_number => 6)],
          :filename         => project_file,
          :coverage         => [0,3,2,nil,1,0],
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
              "coverage" => "[0,3,2,null,null,null]",
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

      stub = stub_request(:post, "http://cc.dev/test_reports").
        with(:headers => {'Content-Encoding'=>'gzip', 'Content-Type'=>'application/json', 'User-Agent'=>"Code Climate (Ruby Test Reporter v#{CodeClimate::TestReporter::VERSION})"})
      requests = capture_requests(stub)

      formatter.format(simplecov_result)

      uncompressed = inflate(requests.first.body)
      expected_request.merge!("ci_service" => Ci.service_data)
      expected_json = JSON.parse(expected_request.to_json, symbolize_names: true)
      expect(JSON.parse(uncompressed, symbolize_names: true)).to eq(expected_json)
    end

    describe '#short_filename' do
      it 'should return the filename of the file relative to the SimpleCov root' do
        expect(formatter.send(:short_filename, 'file1')).to eq('file1')
        expect(formatter.send(:short_filename, "#{::SimpleCov.root}/file1")).to eq('file1')
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
          expect(formatter.send(:short_filename, 'file1')).to eq('custom/file1')
          expect(formatter.send(:short_filename, "#{::SimpleCov.root}/file1")).to eq('custom/file1')
        end
      end

      it "should not strip the subdirectory if it has the same name as the root" do
        expect(formatter.send(:short_filename, "#{::SimpleCov.root}/#{::SimpleCov.root}/file1")).to eq("#{::SimpleCov.root}/file1")
      end
    end
  end
end
