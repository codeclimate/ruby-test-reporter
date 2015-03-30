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

      before { expect(SecureRandom).to receive(:uuid).and_return uuid }
      around { |test| Dir.mktmpdir { |dir| Dir.chdir(dir, &test) } }

      it "posts a single file" do
        File.write("a", "Something")
        requests = capture_requests(stub_request(:post, "http://cc.dev/test_reports/batch"))
        Client.new.batch_post_results(["a"])

        expect(requests.first.body).to eq "--#{uuid}\r\nContent-Disposition: form-data; name=\"repo_token\"\r\n\r\n#{token}\r\n--#{uuid}\r\nContent-Disposition: form-data; name=\"coverage_reports[0]\"; filename=\"a\"\r\nContent-Type: application/json\r\n\r\nSomething\r\n--#{uuid}--\r\n"
      end
    end
  end
end
