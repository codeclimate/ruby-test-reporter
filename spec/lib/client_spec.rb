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
  end
end
