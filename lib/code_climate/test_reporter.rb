module CodeClimate
  module TestReporter

    def self.start
      if run?
        require "simplecov"
        ::SimpleCov.add_filter 'vendor'
        ::SimpleCov.formatter = Formatter
        ::SimpleCov.start(configuration.profile) do
          skip_token CodeClimate::TestReporter.configuration.skip_token
        end
      end
    end

    def self.run?
      environment_variable_set? && run_on_current_branch?
    end

    def self.environment_variable_set?
      return @environment_variable_set if defined?(@environment_variable_set)

      @environment_variable_set = !!ENV["CODECLIMATE_REPO_TOKEN"]
      if @environment_variable_set
        logger.info("Reporting coverage data to Code Climate.")
      end

      @environment_variable_set
    end

    def self.run_on_current_branch?
      return @run_on_current_branch if defined?(@run_on_current_branch)

      @run_on_current_branch = true if configured_branch.nil?
      @run_on_current_branch ||= !!(current_branch =~ /#{configured_branch}/i)

      unless @run_on_current_branch
        logger.info("Not reporting to Code Climate because #{configured_branch} is set as the reporting branch.")
      end

      @run_on_current_branch
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
