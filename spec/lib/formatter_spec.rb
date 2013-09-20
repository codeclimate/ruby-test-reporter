require 'spec_helper'

module CodeClimate::TestReporter
  describe Formatter do
    let(:formatter) { Formatter.new }
    let(:files) {
      [
        mock(
          :lines            => [mock, mock, mock],
          :covered_lines    => [mock, mock],
          :missed_lines     => [mock],
          :filename         => "lib/code_climate/test_reporter.rb",
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

    it "sends an http request with all the coverage information" do
      app = MyRackApp.new do |env|
        env["PATH_INFO"].should == "/test_reports"
        puts JSON.parse(env["rack.input"].string).should ==
          {
            "repo_token" => "172754c1bf9a3c698f7770b9fb648f1ebb214425120022d0b2ffc65b97dff531",
            "source_files" =>
              [
                {
                  "name" => "lib/code_climate/test_reporter.rb",
                  "blob_id" => "bfa3656d591dab2cf9ca6d3df53aac71974a45f4",
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
                "head" => "0ebc98c64d39fe40d362dcc555b76230a07b8732",
                "committed_at" => 1379702812,
                "branch" => "master"
              },
            "environment" =>
              {
                "test_framework" => "rspec",
                "pwd" => "/Users/noah/p/ruby-test-reporter",
                "rails_root" => nil,
                "simplecov_root" => "/Users/noah/p/ruby-test-reporter",
                "gem_version" => "0.0.11"
              },
            "ci_service" => {}
          }
      end

      Artifice.activate_with(app) do
        formatter.format(simplecov_result)
      end
    end
  end
end
