module CodeClimate
  module TestReporter

    def self.start
      if run?
        require "simplecov"
        ::SimpleCov.add_filter 'vendor'
        ::SimpleCov.formatter = Formatter
        ::SimpleCov.start("test_frameworks")
      end
    end

    def self.run?
      environment_variable_set? && run_on_current_branch?
    end

    def self.environment_variable_set?
      environment_variable_set = !!ENV["CODECLIMATE_REPO_TOKEN"]
      unless environment_variable_set
        logger.info("Not reporting to Code Climate because ENV['CODECLIMATE_REPO_TOKEN'] is not set.")
      end

      environment_variable_set
    end

    def self.run_on_current_branch?
      return true if configured_branch.nil?

      run_on_current_branch = !!(current_branch =~ /#{configured_branch}/i)
      unless run_on_current_branch
        logger.info("Not reporting to Code Climate because #{configured_branch} is set as the reporting branch.")
      end

      run_on_current_branch
    end

    def self.configured_branch
      configuration.branch
    end

    def self.current_branch
      Git.branch_from_git_or_ci
    end

    def self.logger
      CodeClimate::TestReporter.configuration.logger
    end

  end
end
