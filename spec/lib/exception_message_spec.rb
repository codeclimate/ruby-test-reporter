require 'spec_helper'

module CodeClimate::TestReporter
  describe ExceptionMessage do
    ExceptionMessage::HTTP_STUBBING_MESSAGES.keys.each do |type|
      let(:subject) { ExceptionMessage.new(nil) }

      context "when #{type} is raised" do
        before do
          allow(subject).to receive(:exception_class).and_return type
        end

        it "defaults to codeclimate.com when CODECLIMATE_API_HOST is not set" do
          ENV['CODECLIMATE_API_HOST'] = nil
          expect(subject.message).to include "'codeclimate.com'"
        end

        it "uses CODECLIMATE_API_HOST when CODECLIMATE_API_HOST is set" do
          ENV['CODECLIMATE_API_HOST'] = 'http://cc.dev'
          expect(subject.message).to include "'cc.dev'"
        end
      end
    end
  end
end
