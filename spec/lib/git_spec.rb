require 'spec_helper'

module CodeClimate::TestReporter
  describe Git do
    describe '.info' do
      it 'returns a hash with git information.' do
        expected_git_hash = {
          head: `git log -1 --pretty=format:'%H'`,
          committed_at: `git log -1 --pretty=format:%ct`.to_i,
          branch: Git.send(:branch_from_git)
        }

        expect(Git.info).to include expected_git_hash
      end
    end

    describe 'branch_from_git_or_ci' do
      it 'returns the branch from ci' do
        allow(Ci).to receive(:service_data).and_return({branch: 'ci-branch'})

        expect(Git.branch_from_git_or_ci).to eq 'ci-branch'
      end

      it 'returns the branch from git if there is no ci branch' do
        allow(Ci).to receive(:service_data).and_return({})

        expect(Git.branch_from_git_or_ci).to eq Git.clean_git_branch
      end

      it 'returns master otherwise' do
        allow(Ci).to receive(:service_data).and_return({})
        allow(Git).to receive(:branch_from_git).and_return(nil)

        expect(Git.branch_from_git_or_ci).to eq 'master'
      end
    end

  end
end
