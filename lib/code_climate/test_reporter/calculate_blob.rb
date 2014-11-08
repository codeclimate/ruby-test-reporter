module CodeClimate
  module TestReporter

    class CalculateBlob

      def initialize(file_path)
        @file_path = file_path
      end

      def blob_id
        calculate_with_file || calculate_with_git
      end

    private

      def calculate_with_file
        File.open(@file_path, "rb") do |file|
          header = "blob #{file.size}\0"
          content = file.read
          store = header + content

          return Digest::SHA1.hexdigest(store)
        end
      rescue EncodingError
      end

      def calculate_with_git
        Kernel.system("git hash-object -t blob #{@file_path}")
      end

    end

  end
end
