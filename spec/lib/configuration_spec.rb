require 'spec_helper'

module CodeClimate::TestReporter
  describe Configuration do
    describe 'none given' do
      before do
        CodeClimate::TestReporter.configure
      end

      it 'provides defaults' do
        expect(CodeClimate::TestReporter.configuration.show_warnings).to be_true
        expect(CodeClimate::TestReporter.configuration.branch).to be_nil
      end
    end

    describe 'with config block' do
      after do
        CodeClimate::TestReporter.configure
      end

      it 'stores show_warnings' do
        CodeClimate::TestReporter.configure do |config|
          config.show_warnings = false
        end

        expect(CodeClimate::TestReporter.configuration.show_warnings).to be_false
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
