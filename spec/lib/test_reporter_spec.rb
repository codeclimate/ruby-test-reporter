require 'spec_helper'

describe CodeClimate::TestReporter do
  let(:logger) { double.as_null_object }
  let(:reporter) { CodeClimate::TestReporter.dup }

  before do
    allow(CodeClimate::TestReporter.configuration).to receive(:logger).and_return(logger)
  end

  describe '.run_on_current_branch?' do
    it 'returns true if there is no branch configured' do
      allow(reporter).to receive(:configured_branch).and_return(nil)
      expect(reporter).to be_run_on_current_branch
    end

    it 'returns true if the current branch matches the configured branch' do
      allow(reporter).to receive(:current_branch).and_return("master\n")
      allow(reporter).to receive(:configured_branch).and_return(:master)

      expect(reporter).to be_run_on_current_branch
    end

    it 'returns false if the current branch and configured branch dont match' do
      allow(reporter).to receive(:current_branch).and_return("some-branch")
      allow(reporter).to receive(:configured_branch).and_return(:master)

      expect(reporter).to_not be_run_on_current_branch
    end

    it 'logs a message if false' do
      expect(logger).to receive(:info)

      allow(reporter).to receive(:current_branch).and_return("another-branch")
      allow(reporter).to receive(:configured_branch).and_return(:master)

      reporter.run_on_current_branch?
    end
  end

end
