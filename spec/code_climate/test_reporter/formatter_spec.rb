require 'spec_helper'
require 'fileutils'

module CodeClimate::TestReporter
  describe Formatter do
    it "converts simplecov format to code climate http payload format" do
      expect(Git).to receive(:branch_from_git_or_ci).and_return("master")
      formatter = Formatter.new
      formatted_request = within_repository("fake_project") do
        formatter.format(
          "RSpec" => {
            "coverage" => {
              "#{SimpleCov.root}/spec/fixtures/fake_project/fake_project.rb" => [5,3,nil,0]
            },
            "timestamp" => Time.now.to_i,
          }
        )
      end

      expect(formatted_request).to eq(
        ci_service: CodeClimate::TestReporter.ci_service_data,
        covered_percent: 66.67,
        covered_strength: 2.7,
        environment: {
          gem_version: VERSION,
          pwd: "#{Dir.pwd}/spec/fixtures/fake_project",
          rails_root: nil,
          simplecov_root: SimpleCov.root,
        },
        git: {
          branch: "master",
          committed_at: 1474318896,
          head: "7a36651c654c73e7e9a6dfc9f9fa78c5fe37241e",
        },
        line_counts: { total: 4, covered: 2, missed: 1 },
        partial: false,
        repo_token: "172754c1bf9a3c698f7770b9fb648f1ebb214425120022d0b2ffc65b97dff531",
        run_at: Time.now.to_i,
        source_files: [
          {
            blob_id: "84275f9939456e87efd6932bdf7fe01d52a53116",
            coverage: "[5,3,null,0]",
            covered_percent: 66.67,
            covered_strength: 2.7,
            line_counts: { total: 4, covered: 2, missed: 1 },
            name: "spec/fixtures/fake_project/fake_project.rb",
          }
        ],
      )
    end

    it "addresses Issue #7" do
      simplecov_result = load_resultset("issue_7", %r{^.*/i18n-tasks/})
      formatter = Formatter.new
      formatted_request = within_repository("issue_7") do
        formatter.format(simplecov_result)
      end

      expect(formatted_request[:covered_percent]).to be_within(1.0).of(94)
    end
  end
end
