require "json"
require "digest/sha1"
require "net/https"
require "uri"
require "tmpdir"
require "securerandom"

module CodeClimate
  class TestReporter
    VERSION = "0.0.5"

    class API
      def self.host
        ENV["CODECLIMATE_API_HOST"] ||
        "https://codeclimate.com"
      end

      def self.batch_post(files)
        uri = URI.parse("#{host}/test_reports/batch")
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == "https"
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.ca_file = File.expand_path('../../config/cacert.pem', __FILE__)
          http.verify_depth = 5
        end
        http.open_timeout = 5 # in seconds
        http.read_timeout = 5 # in seconds
        boundary = SecureRandom.uuid

        post_body = []
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"repo_token\"\r\n"
        post_body << "\r\n"
        post_body << ENV["CODECLIMATE_REPO_TOKEN"]
        files.each_with_index do |file, index|
          post_body << "\r\n--#{boundary}\r\n"
          post_body << "Content-Disposition: form-data; name=\"coverage_reports[#{index}]\"; filename=\"#{File.basename(file)}\"\r\n"
          post_body << "Content-Type: application/json\r\n"
          post_body << "\r\n"
          post_body << File.read(file)
        end
        post_body << "\r\n--#{boundary}--\r\n"
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = post_body.join
        request["Content-Type"] = "multipart/form-data, boundary=#{boundary}"
        response = http.request(request)

        if response.code.to_i >= 200 && response.code.to_i < 300
          response
        else
          raise "HTTP Error: #{response.code}"
        end
      end

      def self.post_results(result)
        uri = URI.parse("#{host}/test_reports")
        http = Net::HTTP.new(uri.host, uri.port)

        if uri.scheme == "https"
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.ca_file = File.expand_path('../../config/cacert.pem', __FILE__)
          http.verify_depth = 5
        end

        http.open_timeout = 5 # in seconds
        http.read_timeout = 5 # in seconds

        request = Net::HTTP::Post.new(uri.path)
        request["Content-Type"] = "application/json"
        request.body = result.to_json

        response = http.request(request)

        if response.code.to_i >= 200 && response.code.to_i < 300
          response
        else
          raise "HTTP Error: #{response.code}"
        end
      end
    end

    class Formatter
      def format(result)
        print "Coverage = #{result.covered_percent.round(2)}%."

        payload = to_payload(result)
        if tddium? || ENV["TO_FILE"]
          file_path = File.join(Dir.tmpdir, "codeclimate-test-coverage-#{SecureRandom.uuid}.json")
          print "Coverage results saved to #{file_path}..."
          File.open(file_path, "w") { |file| file.write(payload.to_json) }
        else
          print "Sending report to #{API.host}... "
          API.post_results(payload)
        end

        puts "done."
        true
      rescue => ex
        puts "\nCode Climate encountered an exception: #{ex.class}"
        puts ex.message
        ex.backtrace.each do |line|
          puts line
        end
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
            covered_percent:  file.covered_percent.round(2),
            covered_strength: file.covered_strength.round(2),
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
          covered_percent:  result.covered_percent.round(2),
          covered_strength: result.covered_strength.round(2),
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
        content = File.open(path, "rb").read
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
