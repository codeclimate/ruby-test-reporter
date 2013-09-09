require "json"
require "uri"
require "net/https"

module CodeClimate
  module TestReporter

    class Client

      def host
        ENV["CODECLIMATE_API_HOST"] ||
          "https://codeclimate.com"
      end

      def batch_post_results(files)
        uri = URI.parse("#{host}/test_reports/batch")
        http = http_client(uri)

        boundary = SecureRandom.uuid
        post_body = []
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"repo_token\"\r\n"
        post_body << "\r\n"
        post_body << ENV["CODECLIMATE_REPO_TOKEN"]
        files.each_with_index do |file, index|
          post_body << "\r\n--#{boundary}\r\n"
          post_body << "Content-Disposition: form-data; name=\"coverage_reports[#{index}]\"; filename=\"#{File.basename(file)}\"\r\n"
          post_body << "Content-Type: application/json\r\n"
          post_body << "\r\n"
          post_body << File.read(file)
        end
        post_body << "\r\n--#{boundary}--\r\n"
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = post_body.join
        request["Content-Type"] = "multipart/form-data, boundary=#{boundary}"
        response = http.request(request)

        if response.code.to_i >= 200 && response.code.to_i < 300
          response
        else
          raise "HTTP Error: #{response.code}"
        end
      end

      def post_results(result)
        uri = URI.parse("#{host}/test_reports")
        http = http_client(uri)

        request = Net::HTTP::Post.new(uri.path)
        request["Content-Type"] = "application/json"
        request.body = result.to_json

        response = http.request(request)

        if response.code.to_i >= 200 && response.code.to_i < 300
          response
        else
          raise "HTTP Error: #{response.code}"
        end
      end

    private

      def http_client(uri)
        Net::HTTP.new(uri.host, uri.port).tap do |http|
          if uri.scheme == "https"
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            http.ca_file = File.expand_path('../../../../config/cacert.pem', __FILE__)
            http.verify_depth = 5
          end
          http.open_timeout = 5 # in seconds
          http.read_timeout = 5 # in seconds
        end
      end

    end

  end
end
