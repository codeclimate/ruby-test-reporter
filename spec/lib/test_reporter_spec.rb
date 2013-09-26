require 'spec_helper'

describe CodeClimate::TestReporter do

  describe '.run_on_current_branch?' do
    it 'returns true if there is no branch configured' do
      allow(CodeClimate::TestReporter).to receive(:configured_branch).and_return(nil)
      expect(CodeClimate::TestReporter.run_on_current_branch?).to be_true
    end

    it 'returns true if the current branch matches the configured branch' do
      allow(CodeClimate::TestReporter).to receive(:current_branch).and_return("master\n")
      allow(CodeClimate::TestReporter).to receive(:configured_branch).and_return(:master)

      expect(CodeClimate::TestReporter.run_on_current_branch?).to be_true
    end

    it 'returns false if the current branch and configured branch dont match' do
      allow(CodeClimate::TestReporter).to receive(:current_branch).and_return("some-branch")
      allow(CodeClimate::TestReporter).to receive(:configured_branch).and_return(:master)

      expect(CodeClimate::TestReporter.run_on_current_branch?).to be_false
    end
  end

end
