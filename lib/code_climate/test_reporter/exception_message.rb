module CodeClimate
  module TestReporter

    class WebMockMessage
      def library_name
        "WebMock"
      end

      def instructions(api_host)
      <<-STR
  WebMock.disable_net_connect!(:allow => '#{api_host}')
STR
      end
    end

    class VCRMessage
      def library_name
        "VCR"
      end

      def instructions(api_host)
      <<-STR
  VCR.configure do |config|
    # your existing configuration
    config.ignore_hosts '#{api_host}'
  end
STR
      end
    end

    class ExceptionMessage

      HTTP_STUBBING_MESSAGES = {
        "VCR::Errors::UnhandledHTTPRequestError" => VCRMessage,
        "WebMock::NetConnectNotAllowedError"     => WebMockMessage
      }

      def initialize(exception)
        @exception = exception
      end

      def message
        api_host = URI(ENV["CODECLIMATE_API_HOST"] || "https://codeclimate.com").host
        parts = []
        parts << "Code Climate encountered an exception: #{exception_class}"
        if http_stubbing_exception
          message = http_stubbing_exception.new
          parts << "======"
          parts << "Hey! Looks like you are using #{message.library_name}, which will prevent the codeclimate-test-reporter from reporting results to #{api_host}.
Add the following to your spec or test helper to ensure codeclimate-test-reporter can post coverage results:"
          parts << "\n" + message.instructions(api_host) + "\n"
          parts << "======"
          parts << "If this doesn't work, please consult https://codeclimate.com/docs#test-coverage-troubleshooting"
          parts << "======"
        else
          parts << @exception.message
          @exception.backtrace.each do |line|
            parts << line
          end
        end
        parts.join("\n")
      end

    private

      def exception_class
        @exception.class.to_s
      end

      def http_stubbing_exception
        HTTP_STUBBING_MESSAGES[exception_class]
      end
    end
  end
end
