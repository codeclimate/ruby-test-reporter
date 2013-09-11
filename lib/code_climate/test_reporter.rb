module CodeClimate
  module TestReporter
    VERSION = "0.0.7"

    def self.start
      if run?
        require "simplecov"
        ::SimpleCov.add_filter 'vendor'
        ::SimpleCov.formatter = Formatter
        ::SimpleCov.start("test_frameworks")
        
        if defined?(VCR)
          VCR.configure { |c| c.ignore_hosts "codeclimate.com" }
        end
      else
        puts("Not reporting to Code Climate because ENV['CODECLIMATE_REPO_TOKEN'] is not set.")
      end
    end

    def self.run?
      !!ENV["CODECLIMATE_REPO_TOKEN"]
    end
  end
end
