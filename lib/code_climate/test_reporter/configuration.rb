module CodeClimate
  module TestReporter
    @@configuration = nil

    def self.configure
      @@configuration = Configuration.new

      if block_given?
        yield configuration
      end

      configuration
    end

    def self.configuration
      @@configuration || configure
    end

    class Configuration
      attr_accessor :branch, :logger, :profile

      def logger
        @logger ||= default_logger
      end

      def profile
        @profile ||= (ENV["CODECLIMATE_SIMPLECOV_PROFILE"] || "test_frameworks")
      end

      private

      def default_logger
        log = Logger.new($stderr)
        log.level = Logger::INFO

        log
      end
    end

  end
end
