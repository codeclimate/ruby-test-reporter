require "json"

module CodeClimate
  class TestReporter
    VERSION = "0.0.1"

    class API
      def self.post_results(result)
        result = result.merge(environment: Environment.new.as_json)
        puts result.inspect
      end
    end

    class Environment
      def as_json
        {
          repo_token:     ENV["CODECLIMATE_REPO_TOKEN"],
          pwd:            Dir.pwd,
          rails_root:     (Rails.root.to_s rescue nil),
          simplecov_root: ::SimpleCov.root,
          gem_version:    VERSION,
          git: {
            head:   `git log -1 --pretty=format:'%H'`,
            branch: git_branch,
          }
        }
      end

      def git_branch
        branch = `git branch`.split("\n").delete_if { |i| i[0] != "*" }
        branch = [branch].flatten.first
        branch ? branch.gsub("* ","") : nil
      end
    end

    class Formatter
      def format(result)
        source_files = result.files.map do |file|
          {
            name:     short_filename(file.filename),
            coverage: file.coverage
          }
        end

        API.post_results({
          source_files:   source_files,
          test_framework: result.command_name.downcase,
          run_at:         result.created_at
        })

        true
      end

      def short_filename(filename)
        return filename unless ::SimpleCov.root
        filename.gsub(::SimpleCov.root, '.').gsub(/^\.\//, '')
      end
    end

    def self.start
      require "simplecov"
      ::SimpleCov.add_filter 'vendor'
      ::SimpleCov.formatter = Formatter
      ::SimpleCov.start("test_frameworks")
    end
  end
end
