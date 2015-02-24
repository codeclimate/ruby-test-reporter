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

    describe 'git' do
      it 'should quote the git repository directory' do
        path = '/path/to/foo bar'

        allow(CodeClimate::TestReporter.configuration).to receive(:git_dir).and_return path
        expect(Git).to receive(:`).once.with "git --git-dir=\"#{path}/.git\" help"

        Git.send :git, 'help'
      end

      context 'ensure logic that replies on Rails is robust in non-rails environments' do
        before :all do
          module ::Rails; end
        end

        after :all do
          Object.send(:remove_const, :Rails)
        end

        after :each do
          Git.send :git, 'help'
        end

        it 'will check if constant Rails is defined' do
          expect(Git).to receive(:configured_git_dir).once.and_return(nil)
        end

        it 'will not call method "root" (a 3rd time) if constant Rails is defined but does not respond to root' do
          expect(Git).to receive(:configured_git_dir).once.and_return(nil)
          expect(Rails).to receive(:root).twice.and_return('/path')
        end

        it 'will call rails root if constant Rails is defined and root method is defined' do
          module ::Rails
            def self.root
              '/path'
            end
          end
          expect(Git).to receive(:configured_git_dir).once.and_return(nil)
          expect(Rails).to receive(:root).twice.and_return('/path')
        end
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
