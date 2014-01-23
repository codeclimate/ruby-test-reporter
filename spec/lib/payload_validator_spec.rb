require 'spec_helper'

module CodeClimate::TestReporter
  describe PayloadValidator do
    let(:payload) {
      {
        git: {
          committed_at: 1389603672,
          head:         "4b968f076d169c3d98089fba27988f0d52ba803d"
        },
        run_at: 1379704336,
        source_files: [
          { coverage: "[0,3,4]", name: "user.rb" }
        ]
      }
    }

    it "does not raise if there's a minimally valid test report payload" do
      expect {
        PayloadValidator.validate(payload)
      }.to_not raise_error
    end

    it "raises when there's no commit sha" do
      payload[:git][:head] = nil
      expect {
        PayloadValidator.validate(payload)
      }.to raise_error(InvalidPayload, /A git commit sha was not found/)
    end

    it "does not raise if there's a commit sha in ci_service data" do
      payload[:git][:head] = nil
      payload[:ci_service] = {}
      payload[:ci_service][:commit_sha] = "4b968f076d169c3d98089fba27988f0d52ba803d"
      expect {
        PayloadValidator.validate(payload)
      }.to_not raise_error
    end

    it "raises when there is no committed_at" do
      payload[:git][:committed_at] = nil
      expect {
        PayloadValidator.validate(payload)
      }.to raise_error(InvalidPayload, /A git commit timestamp was not found/)
    end

    it "raises when there's no run_at" do
      payload[:run_at] = nil
      expect {
        PayloadValidator.validate(payload)
      }.to raise_error(InvalidPayload, /A run at timestamp was not found/)
    end

    it "raises when no source_files parameter is passed" do
      payload[:source_files] = nil
      expect {
        PayloadValidator.validate(payload)
      }.to raise_error(InvalidPayload, /No source files were found/)
    end

    it "raises when there's no source files" do
      payload[:source_files] = []
      expect {
        PayloadValidator.validate(payload)
      }.to raise_error(InvalidPayload, /No source files were found/)
    end

    it "raises if source files aren't hashes" do
      payload[:source_files] = [1,2,3]
      expect {
        PayloadValidator.validate(payload)
      }.to raise_error(InvalidPayload, /Invalid source files/)
    end

    it "raises if source files don't have names" do
      payload[:source_files] = [{ coverage: "[1,1]" }]
      expect {
        PayloadValidator.validate(payload)
      }.to raise_error(InvalidPayload, /Invalid source files/)
    end

    it "raises if source files don't have coverage" do
      payload[:source_files] = [{ name: "foo.rb" }]
      expect {
        PayloadValidator.validate(payload)
      }.to raise_error(InvalidPayload, /Invalid source files/)
    end
  end
end
