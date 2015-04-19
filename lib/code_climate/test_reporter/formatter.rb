# encoding: utf-8

require "tmpdir"
require "securerandom"
require "json"
require "digest/sha1"
require "simplecov"

require "code_climate/test_reporter/exception_message"
require "code_climate/test_reporter/payload_validator"

module CodeClimate
  module TestReporter
    class Formatter
      def format(result)
        return true unless CodeClimate::TestReporter.run?

        print "Coverage = #{result.source_files.covered_percent.round(2)}%. "

        payload = to_payload(result)
        PayloadValidator.validate(payload)
        if write_to_file?
          file_path = File.join(Dir.tmpdir, "codeclimate-test-coverage-#{SecureRandom.uuid}.json")
          print "Coverage results saved to #{file_path}... "
          File.open(file_path, "w") { |file| file.write(payload.to_json) }
        else
          client = Client.new
          print "Sending report to #{client.host} for branch #{Git.branch_from_git_or_ci}... "
          client.post_results(payload)
        end

        puts "done."
        true
      rescue => ex
        puts ExceptionMessage.new(ex).message
        false
      end

      # actually private ...
      def short_filename(filename)
        return filename unless ::SimpleCov.root
        filename = filename.gsub(::SimpleCov.root, '.').gsub(/^\.\//, '')
        apply_prefix filename
      end

    private

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
            blob_id:          CalculateBlob.new(file.filename).blob_id,
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
          run_at:           result.created_at.to_i,
          covered_percent:  result.source_files.covered_percent.round(2),
          covered_strength: result.source_files.covered_strength.round(2),
          line_counts:      totals,
          partial:          partial?,
          git: Git.info,
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

      def tddium?
        ci_service_data && ci_service_data[:name] == "tddium"
      end

      # Convert to Float before rounding.
      # Fixes [#7] possible segmentation fault when calling #round on a Rational
      def round(numeric, precision)
        Float(numeric).round(precision)
      end

      def write_to_file?
        warn "TO_FILE is deprecated, use CODECLIMATE_TO_FILE" if ENV["TO_FILE"]
        tddium? || ENV["CODECLIMATE_TO_FILE"] || ENV["TO_FILE"]
      end

      def apply_prefix filename
        prefix = CodeClimate::TestReporter.configuration.path_prefix
        return filename if prefix.nil?
        "#{prefix}/#{filename}"
      end

      def ci_service_data
        @ci_service_data ||= Ci.service_data
      end
    end
  end
end
