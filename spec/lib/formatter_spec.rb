require 'spec_helper'
require 'fileutils'

module CodeClimate::TestReporter
  describe Formatter do
    let(:formatter) { Formatter.new }

    let(:expected_request) {
      {
        repo_token: "172754c1bf9a3c698f7770b9fb648f1ebb214425120022d0b2ffc65b97dff531",
        source_files:
          [
            {
              name:  "spec/fixtures/fake_project/fake_project.rb",
              blob_id:  "84275f9939456e87efd6932bdf7fe01d52a53116",
              coverage:  "[5,3,null,0]",
              covered_percent:  66.67,
              covered_strength:  2.7,
              line_counts:  { total: 4, covered: 2, missed: 1}
            }
          ],
        run_at:  Time.now.to_i,
        covered_percent:  66.67,
        covered_strength:  2.7,
        line_counts:  { total:  4, covered:  2, missed:  1 },
        partial: false,
        git:
          {
            head:  "7a36651c654c73e7e9a6dfc9f9fa78c5fe37241e",
            committed_at:  1474318896,
            branch:  "master"
          },
        environment:
          {
            test_framework:  "rspec",
            pwd:  Dir.pwd,
            rails_root:  nil,
            simplecov_root: SimpleCov.root,
            gem_version:  VERSION
          },
      }.merge!(ci_service:  CodeClimate::TestReporter.ci_service_data)
    }

    before do
      @old_pwd = Dir.pwd
      FileUtils.cd("#{Dir.pwd}/spec/fixtures")
      `tar -xvzf fake_project.tar.gz`
      FileUtils.cd("fake_project")
    end

    after do
      FileUtils.rm_rf("#{@old_pwd}/spec/fixtures/fake_project")
      FileUtils.cd(@old_pwd)
    end

    it "converts simplecov format to code climate http payload format" do
      simplecov_result = { "RSpec" =>
          { "coverage" =>
            { "#{SimpleCov.root}/spec/fixtures/fake_project/fake_project.rb" => [5,3,nil,0] }
          }
      }
      expect(formatter.format(simplecov_result)).to eq(expected_request)
    end
  end
end
