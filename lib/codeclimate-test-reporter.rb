require "json"

module CodeClimate
  class TestReporter
    VERSION = "0.0.1"

    class API
      def self.base
        "https://codeclimate.com"
      end

      def self.post_results(result)
      end
    end

    class Formatter
      def format(result)
        totals = Hash.new(0)

        source_files = result.files.map do |file|
          totals[:total]      += file.lines.count
          totals[:covered]    += file.covered_lines.count
          totals[:missed]     += file.missed_lines.count

          {
            name:             short_filename(file.filename),
            coverage:         file.coverage.to_json,
            covered_percent:  file.covered_percent.round(2),
            covered_strength: file.covered_strength.round(2),
            line_counts: {
              total:    file.lines.count,
              covered:  file.covered_lines.count,
              missed:   file.missed_lines.count
            }
          }
        end

        puts "Coverage = #{result.covered_percent.round(2)}%.\nSending report to #{API.base} ..."

        API.post_results({
          repo_token:       ENV["CODECLIMATE_REPO_TOKEN"],
          source_files:     source_files,
          run_at:           result.created_at,
          covered_percent:  result.covered_percent.round(2),
          covered_strength: result.covered_strength.round(2),
          line_counts:      totals,
          git: {
            head:         `git log -1 --pretty=format:'%H'`,
            committed_at: committed_at,
            branch:       git_branch,
          },
          environment: {
            test_framework: result.command_name.downcase,
            pwd:            Dir.pwd,
            rails_root:     (Rails.root.to_s rescue nil),
            simplecov_root: ::SimpleCov.root,
            gem_version:    VERSION
          }
        })

        puts "Report sent to Code Climate."
        true
      rescue => ex
        puts "Code Climate encountered an exception:"
        puts ex.class.to_s
        puts ex.message
        ex.backtrace.each do |line|
          puts line
        end
        false
      end

      def short_filename(filename)
        return filename unless ::SimpleCov.root
        filename.gsub(::SimpleCov.root, '.').gsub(/^\.\//, '')
      end

      def committed_at
        committed_at = `git log -1 --pretty=format:'%ct'`
        committed_at.to_i.zero? ? nil : committed_at.to_i
      end

      def git_branch
        branch = `git branch`.split("\n").delete_if { |i| i[0] != "*" }
        branch = [branch].flatten.first
        branch ? branch.gsub("* ","") : nil
      end
    end

    def self.start
      if run?
        require "simplecov"
        ::SimpleCov.add_filter 'vendor'
        ::SimpleCov.formatter = Formatter
        ::SimpleCov.start("test_frameworks")
      else
        puts("Not reporting to Code Climate because ENV['CODECLIMATE_REPO_TOKEN'] is not set.")
      end
    end

    def self.run?
      !!ENV["CODECLIMATE_REPO_TOKEN"]
    end
  end
end
