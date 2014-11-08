require 'spec_helper'

module CodeClimate::TestReporter

  describe CalculateBlob do

    subject { CalculateBlob.new(fixture) }
    let(:fixture) { File.expand_path("../../fixtures/encoding_test.rb", __FILE__) }

    it 'hex digests content of file' do
      expect(subject.blob_id).to_not be_nil
    end

    context 'encoding error' do

      let(:fixture) { File.expand_path("../../fixtures/encoding_test_iso.rb", __FILE__) }

      it 'falls back to git' do
        expect(File).to receive(:open).and_raise(EncodingError)
        expect(Kernel).to receive(:system).with("git hash-object -t blob #{fixture}").and_return('123')
        expect(subject.blob_id).to eq('123')
      end

    end

  end

end
