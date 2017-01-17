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
        expect(CodeClimate::TestReporter.configuration.profile).to eq('test_frameworks')
        expect(CodeClimate::TestReporter.configuration.path_prefix).to be_nil
        expect(CodeClimate::TestReporter.configuration.skip_token).to eq('nocov')
        expect(CodeClimate::TestReporter.configuration.timeout).to eq(Client::DEFAULT_TIMEOUT)
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

      it 'stores profile' do
        CodeClimate::TestReporter.configure do |config|
          config.profile = 'custom'
        end

        expect(CodeClimate::TestReporter.configuration.profile).to eq('custom')
      end

      it 'stores path prefix' do
        CodeClimate::TestReporter.configure do |config|
          config.path_prefix = 'custom'
        end

        expect(CodeClimate::TestReporter.configuration.path_prefix).to eq('custom')

        CodeClimate::TestReporter.configure do |config|
          config.path_prefix = nil
        end
      end

      it 'stores timeout' do
        CodeClimate::TestReporter.configure do |config|
          config.timeout = 666
        end

        expect(CodeClimate::TestReporter.configuration.timeout).to eq(666)
      end
    end
  end
end
