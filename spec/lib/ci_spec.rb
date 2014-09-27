require 'spec_helper'

module CodeClimate::TestReporter
  describe Ci do

    describe '.service_data' do
      before :each do
        @env = {
          'SEMAPHORE' => 'yes?',
          'BRANCH_NAME' => 'master',
          'SEMAPHORE_BUILD_NUMBER' => '1234'
        }
      end

      it 'returns a hash of CI environment info' do
        expected_semaphore_hash = {
          name: 'semaphore',
          branch: 'master',
          build_identifier: '1234'
        }

        expect(Ci.service_data(@env)).to include expected_semaphore_hash
      end
    end
  end
end
