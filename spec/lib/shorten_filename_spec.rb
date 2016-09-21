require 'spec_helper'
require 'fileutils'

module CodeClimate::TestReporter
  describe ShortenFilename do
    let(:shorten_filename){ ShortenFilename.new('file1') }
    let(:shorten_filename_with_simplecov_root) { ShortenFilename.new("#{::SimpleCov.root}/file1") }
    let(:shorten_filename_with_double_simplecov_root) { ShortenFilename.new("#{::SimpleCov.root}/#{::SimpleCov.root}/file1") }

    describe '#short_filename' do
      it 'should return the filename of the file relative to the SimpleCov root' do
        expect(shorten_filename.send(:short_filename)).to eq('file1')
        expect(shorten_filename_with_simplecov_root.send(:short_filename)).to eq('file1')
      end

      context "with path prefix" do
        before do
          CodeClimate::TestReporter.configure do |config|
            config.path_prefix = 'custom'
          end
        end

        after do
          CodeClimate::TestReporter.configure do |config|
            config.path_prefix = nil
          end
        end

        it 'should include the path prefix if set' do
          expect(shorten_filename.send(:short_filename)).to eq('custom/file1')
          expect(shorten_filename_with_simplecov_root.send(:short_filename)).to eq('custom/file1')
        end
      end

      it "should not strip the subdirectory if it has the same name as the root" do
        expect(shorten_filename_with_double_simplecov_root.send(:short_filename)).to eq("#{::SimpleCov.root}/file1")
      end
    end
  end
end
