require "tmpdir"
require "securerandom"
require "json"
require "digest/sha1"

require "code_climate/test_reporter/exception_message"

module CodeClimate
  module TestReporter
    class Formatter
      def format(result)
        print "Coverage = #{round(result.covered_percent, 2)}%. "

        payload = to_payload(result)
        if tddium? || ENV["TO_FILE"]
          file_path = File.join(Dir.tmpdir, "codeclimate-test-coverage-#{SecureRandom.uuid}.json")
          print "Coverage results saved to #{file_path}... "
          File.open(file_path, "w") { |file| file.write(payload.to_json) }
        else
          client = Client.new
          computed_branch = compute_branch(payload)
          print "Sending report to #{client.host} for branch #{computed_branch}... "
          client.post_results(payload)
        end

        puts "done."
        true
      rescue => ex
        puts ExceptionMessage.new(ex).message
        false
      end

      def partial?
        tddium?
      end

      def to_payload(result)
        totals = Hash.new(0)
        source_files = result.files.map do |file|
          totals[:total]      += file.lines.count
          totals[:covered]    += file.covered_lines.count
          totals[:missed]     += file.missed_lines.count

          {
            name:             short_filename(file.filename),
            blob_id:          calculate_blob_id(file.filename),
            coverage:         file.coverage.to_json,
            covered_percent:  round(file.covered_percent, 2),
            covered_strength: round(file.covered_strength, 2),
            line_counts: {
              total:    file.lines.count,
              covered:  file.covered_lines.count,
              missed:   file.missed_lines.count
            }
          }
        end

        {
          repo_token:       ENV["CODECLIMATE_REPO_TOKEN"],
          source_files:     source_files,
          run_at:           result.created_at,
          covered_percent:  round(result.covered_percent, 2),
          covered_strength: round(result.covered_strength, 2),
          line_counts:      totals,
          partial:          partial?,
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
          },
          ci_service: ci_service_data
        }
      end

      def ci_service_data
        if ENV['TRAVIS']
          {
            name:             "travis-ci",
            branch:           ENV['TRAVIS_BRANCH'],
            build_identifier: ENV['TRAVIS_JOB_ID'],
            pull_request:     ENV['TRAVIS_PULL_REQUEST']
          }
        elsif ENV['CIRCLECI']
          {
            name:             "circlci",
            build_identifier: ENV['CIRCLE_BUILD_NUM'],
            branch:           ENV['CIRCLE_BRANCH'],
            commit_sha:       ENV['CIRCLE_SHA1']
          }
        elsif ENV['SEMAPHORE']
          {
            name:             "semaphore",
            branch:           ENV['BRANCH_NAME'],
            build_identifier: ENV['SEMAPHORE_BUILD_NUMBER']
          }
        elsif ENV['JENKINS_URL']
          {
            name:             "jenkins",
            build_identifier: ENV['BUILD_NUMBER'],
            build_url:        ENV['BUILD_URL'],
            branch:           ENV['GIT_BRANCH'],
            commit_sha:       ENV['GIT_COMMIT']
          }
        elsif ENV['TDDIUM']
          {
            name:             "tddium",
            build_identifier: ENV['TDDIUM_SESSION_ID'],
            worker_id:        ENV['TDDIUM_TID']
          }
        else
          {}
        end
      end

      def calculate_blob_id(path)
        content = File.open(path, "rb") {|f| f.read }
        header = "blob #{content.length}\0"
        store = header + content
        Digest::SHA1.hexdigest(store)
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

      def tddium?
        ci_service_data && ci_service_data[:name] == "tddium"
      end

      def compute_branch(payload)
        git_branch = payload[:git][:branch]
        ci_branch = payload[:ci_service][:branch]

        if ci_branch.to_s.strip.size > 0
          ci_branch.sub(/^origin\//, "")
        elsif git_branch.to_s.strip.size > 0 && !git_branch.to_s.strip.start_with?("(")
          git_branch.sub(/^origin\//, "")
        else
          "master"
        end
      end

      # Convert to Float before rounding.
      # Fixes [#7] possible segmentation fault when calling #round on a Rational
      def round(numeric, precision)
        Float(numeric).round(precision)
      end
    end
  end
end
