module CodeClimate
  module TestReporter

    def self.start
      if run?
        require "simplecov"
        ::SimpleCov.add_filter 'vendor'
        ::SimpleCov.formatter = Formatter
        ::SimpleCov.start("test_frameworks")
      elsif show_warnings?
        puts("Not reporting to Code Climate because ENV['CODECLIMATE_REPO_TOKEN'] is not set.")
      end
    end

    def self.run?
      !!ENV["CODECLIMATE_REPO_TOKEN"] && run_on_current_branch?
    end

    def self.run_on_current_branch?
      return true if configured_branch.nil?
      !!(current_branch =~ /#{configured_branch}/i)
    end

    def self.configured_branch
      configuration.branch
    end

    def self.current_branch
      Git.branch_from_git_or_ci
    end

    def self.show_warnings?
      configuration.show_warnings
    end

  end
end
