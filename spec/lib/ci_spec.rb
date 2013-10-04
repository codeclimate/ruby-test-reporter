require 'spec_helper'

module CodeClimate::TestReporter
  describe Ci do

    describe '.service_data' do
      before :each do
        ENV['SEMAPHORE'] = 'yes?'
        ENV['BRANCH_NAME'] = 'master'
        ENV['SEMAPHORE_BUILD_NUMBER'] = '1234'
      end

      after :each do
        ENV.delete('SEMAPHORE')
        ENV.delete('BRANCH_NAME')
        ENV.delete('SEMAPHORE_BUILD_NUMBER')
      end

      it 'returns a hash of CI environment info' do
        expected_semaphore_hash = {
          name: 'semaphore',
          branch: 'master',
          build_identifier: '1234'
        }

        expect(Ci.service_data).to include expected_semaphore_hash
      end
    end

  end
end
