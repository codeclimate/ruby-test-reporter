module CodeClimate
  module TestReporter
    @@configuration = nil

    def self.configure
      @@configuration = Configuration.new

      if block_given?
        yield configuration
      end

      configuration
    end

    def self.configuration
      @@configuration || configure
    end

    class Configuration
      attr_accessor :branch, :show_warnings

      def show_warnings
        @show_warnings = true if @show_warnings.nil?
        @show_warnings
      end
    end

  end
end
