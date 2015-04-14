require 'spec_helper'

module CodeClimate::TestReporter
  describe Client do
    it 'sets the http timeout per configuration' do
      new_timeout = 969
      CodeClimate::TestReporter.configure do |config|
        config.timeout = new_timeout
      end

      response = double(:response, code: 200)
      net_http = double(:net_http, request: response)
      allow(Net::HTTP).to receive(:new).
        and_return(net_http)

      expect(net_http).to receive(:open_timeout=).
        with(new_timeout)
      expect(net_http).to receive(:read_timeout=).
        with(new_timeout)

      Client.new.post_results("")
    end

    describe "#batch_post_results" do
      let(:uuid) { "my-uuid" }
      let(:token) { ENV["CODECLIMATE_REPO_TOKEN"] }

      around { |test| Dir.mktmpdir { |dir| Dir.chdir(dir, &test) } }

      it "posts a single file" do
        File.write("a", '{"Some":"Thing"}')
        requests = capture_requests(stub_request(:post, "http://cc.dev/test_reports"))
        Client.new.batch_post_results(["a"])

        expect(inflate(requests.first.body)).to eq '{"Some":"Thing"}'
      end

      it "merges multiple files" do
        a = {
          "source_files" => [
            {"name" => "a", "coverage" => "[null,0,0,null]", "foo" => "bar", "line_counts" => {"total" => 4, "covered" => 0, "missed" => 2}}
          ],
          "line_counts" => {"total" => 4, "covered" => 0, "missed" => 2}
        }
        File.write("a", a.to_json)

        b = {
          "source_files" => [
            {"name" => "a", "coverage" => "[null,3,0,null]", "line_counts" => {"total" => 4, "covered" => 1, "missed" => 1}},
            {"name" => "b", "coverage" => "[null,1,1,null]", "line_counts" => {"total" => 4, "covered" => 2, "missed" => 0}, "covered_percent" => 100.0}
          ],
          "line_counts" => {"total" => 8, "covered" => 3, "missed" => 1}
        }
        File.write("b", b.to_json)

        requests = capture_requests(stub_request(:post, "http://cc.dev/test_reports"))
        Client.new.batch_post_results(["a", "b"])

        expect(JSON.load(inflate(requests.first.body))).to eq(
          "source_files"=>[
            {"name"=>"a", "coverage"=>"[null,3,0,null]", "foo"=>"bar", "line_counts"=>{"total"=>4, "covered"=>1, "missed"=>1}, "covered_percent"=>50.0},
            {"name"=>"b", "coverage"=>"[null,1,1,null]", "line_counts"=>{"total"=>4, "covered"=>2, "missed"=>0}, "covered_percent"=>100.0}
          ],
          "line_counts"=>{"total"=>8, "covered"=>3, "missed"=>1}
        )
      end
    end
  end
end
