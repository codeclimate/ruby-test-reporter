require 'spec_helper'
require 'logger'

module CodeClimate::TestReporter
  describe Configuration do
    describe 'none given' do
      before do
        CodeClimate::TestReporter.configure
      end

      it 'provides defaults' do
        expect(CodeClimate::TestReporter.configuration.branch).to be_nil
        expect(CodeClimate::TestReporter.configuration.logger).to be_instance_of Logger
        expect(CodeClimate::TestReporter.configuration.logger.level).to eq Logger::INFO
      end
    end

    describe 'with config block' do
      after do
        CodeClimate::TestReporter.configure
      end

      it 'stores logger' do
        logger = Logger.new($stderr)

        CodeClimate::TestReporter.configure do |config|
          logger.level = Logger::DEBUG
          config.logger = logger
        end

        expect(CodeClimate::TestReporter.configuration.logger).to eq logger
      end

      it 'stores branch' do
        CodeClimate::TestReporter.configure do |config|
          config.branch = :master
        end

        expect(CodeClimate::TestReporter.configuration.branch).to eq :master
      end
    end
  end
end
