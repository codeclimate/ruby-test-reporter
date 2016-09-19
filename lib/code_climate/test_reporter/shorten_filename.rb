module CodeClimate
  module TestReporter
    class ShortenFilename
      def initialize(filename)
        @filename = filename
      end

      def short_filename
        return @filename unless ::SimpleCov.root
        apply_prefix @filename.gsub(/^#{::SimpleCov.root}/, ".").gsub(%r{^\./}, "")
      end

      private

      def apply_prefix(filename)
        prefix = CodeClimate::TestReporter.configuration.path_prefix
        return filename if prefix.nil?
        "#{prefix}/#{filename}"
      end
    end
  end
end
