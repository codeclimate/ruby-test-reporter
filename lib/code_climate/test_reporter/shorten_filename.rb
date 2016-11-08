require "pathname"

module CodeClimate
  module TestReporter
    class ShortenFilename
      def initialize(filename)
        @filename = filename
        root = ::SimpleCov.root
        @root = Pathname.new(root) if root
      end

      def short_filename
        return @filename unless root
        path = Pathname.new(@filename)
        shorter =
          if path.relative?
            path
          else
            path.relative_path_from(root)
          end

        if (prefix = CodeClimate::TestReporter.configuration.path_prefix)
          Pathname.new(prefix).join(shorter).to_s
        else
          shorter.to_s
        end
      end

      private

      attr_reader :root
    end
  end
end
