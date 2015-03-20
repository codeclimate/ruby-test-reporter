require "json"
require "uri"
require "net/https"

module CodeClimate
  module TestReporter

    class Client

      DEFAULT_TIMEOUT = 5 # in seconds
      USER_AGENT      = "Code Climate (Ruby Test Reporter v#{VERSION})"

      def host
        ENV["CODECLIMATE_API_HOST"] ||
          "https://codeclimate.com"
      end

      def batch_post_results(files)
        return if files.size == 0
        file, content = unify_simplecov(files)
        uri = URI.parse("#{host}/test_reports/batch")
        http = http_client(uri)

        boundary = SecureRandom.uuid
        post_body = []
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"repo_token\"\r\n"
        post_body << "\r\n"
        post_body << ENV["CODECLIMATE_REPO_TOKEN"]
        post_body << "\r\n--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"coverage_reports[0]\"; filename=\"#{File.basename(file)}\"\r\n"
        post_body << "Content-Type: application/json\r\n"
        post_body << "\r\n"
        post_body << content
        post_body << "\r\n--#{boundary}--\r\n"
        request = Net::HTTP::Post.new(uri.request_uri)
        request["User-Agent"] = USER_AGENT
        request.body = post_body.join
        request["Content-Type"] = "multipart/form-data, boundary=#{boundary}"
        response = http.request(request)

        if response.code.to_i >= 200 && response.code.to_i < 300
          response
        else
          raise "HTTP Error: #{response.code}"
        end
      end

      def post_results(result)
        uri = URI.parse("#{host}/test_reports")
        http = http_client(uri)

        request = Net::HTTP::Post.new(uri.path)
        request["User-Agent"] = USER_AGENT
        request["Content-Type"] = "application/json"

        if CodeClimate::TestReporter.configuration.gzip_request
          request["Content-Encoding"] = "gzip"
          request.body = compress(result.to_json)
        else
          request.body = result.to_json
        end

        response = http.request(request)

        if response.code.to_i >= 200 && response.code.to_i < 300
          response
        else
          raise "HTTP Error: #{response.code}"
        end
      end

    private

      # turn 10 files into 1 file with the sum of all coverages
      def unify_simplecov(coverage_files)
        return [coverage_files.first, File.read(coverage_files.first)] if coverage_files.size == 1

        combined = coverage_files.shift
        puts "Unifying #{coverage_files.size + 1} files into #{combined}"

        report = JSON.load(File.read(combined))
        coverage_files.each do |file|
          merge_source_files(report, JSON.load(File.read(file)).fetch("source_files"))
        end
        recalculate_counters(report)
        [combined, report.to_json]
      end

      def recalculate_counters(report)
        source_files = report.fetch("source_files").map { |s| s["line_counts"] }
        report["line_counts"].keys.each do |k|
          report["line_counts"][k] = source_files.map { |s| s[k] }.inject(:+)
        end
      end

      def merge_source_files(report, source_files)
        all = report.fetch("source_files")
        source_files.each do |new_file|
          old_file = all.detect { |source_file| source_file["name"] == new_file["name"] }

          if old_file
            # merge source files
            coverage = merge_coverage(
              JSON.load(new_file.fetch("coverage")),
              JSON.load(old_file.fetch("coverage"))
            )
            old_file["coverage"] = JSON.dump(coverage)

            total = coverage.size
            missed, covered = coverage.compact.partition { |l| l == 0 }.map(&:size)
            old_file["covered_percent"] = covered * 100.0 / (covered + missed)
            old_file["line_counts"] = {"total" => total, "covered" => covered, "missed" => missed}
          else
            # just use the new value
            all << new_file
          end
        end
      end

      # [nil,1,0] + [nil,nil,2] -> [nil,1,2]
      def merge_coverage(a,b)
        b.map! do |b_count|
          a_count = a.shift
          (!b_count && !a_count) ? nil : b_count.to_i + a_count.to_i
        end
      end

      def http_client(uri)
        Net::HTTP.new(uri.host, uri.port).tap do |http|
          if uri.scheme == "https"
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            http.ca_file = File.expand_path('../../../../config/cacert.pem', __FILE__)
            http.verify_depth = 5
          end
          http.open_timeout = CodeClimate::TestReporter.configuration.timeout
          http.read_timeout = CodeClimate::TestReporter.configuration.timeout
        end
      end

      def compress(str)
        sio = StringIO.new("w")
        gz = Zlib::GzipWriter.new(sio)
        gz.write(str)
        gz.close
        sio.string
      end

    end

  end
end
