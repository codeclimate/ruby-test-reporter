module CodeClimate
  module TestReporter
    class Ci

      def self.service_data(env = ENV)
        if env['TRAVIS']
          {
            name:             "travis-ci",
            branch:           env['TRAVIS_BRANCH'],
            build_identifier: env['TRAVIS_JOB_ID'],
            pull_request:     env['TRAVIS_PULL_REQUEST']
          }
        elsif env['CIRCLECI']
          {
            name:             "circlci",
            build_identifier: env['CIRCLE_BUILD_NUM'],
            branch:           env['CIRCLE_BRANCH'],
            commit_sha:       env['CIRCLE_SHA1']
          }
        elsif env['SEMAPHORE']
          {
            name:             "semaphore",
            branch:           env['BRANCH_NAME'],
            build_identifier: env['SEMAPHORE_BUILD_NUMBER']
          }
        elsif env['JENKINS_URL']
          {
            name:             "jenkins",
            build_identifier: env['BUILD_NUMBER'],
            build_url:        env['BUILD_URL'],
            branch:           env['GIT_BRANCH'],
            commit_sha:       env['GIT_COMMIT']
          }
        elsif env['TDDIUM']
          {
            name:             "tddium",
            build_identifier: env['TDDIUM_SESSION_ID'],
            worker_id:        env['TDDIUM_TID']
          }
        elsif env['WERCKER']
          {
            name:             "wercker",
            build_identifier: env['WERCKER_BUILD_ID'],
            build_url:        env['WERCKER_BUILD_URL'],
            branch:           env['WERCKER_GIT_BRANCH'],
            commit_sha:       env['WERCKER_GIT_COMMIT']
          }
        elsif env['APPVEYOR']
          {
            name:             "appveyor",
            build_identifier: env['APPVEYOR_BUILD_ID'],
            build_url:        env['APPVEYOR_API_URL'],
            branch:           env['APPVEYOR_REPO_BRANCH'],
            commit_sha:       env['APPVEYOR_REPO_COMMIT'],
            pull_request:     env['APPVEYOR_PULL_REQUEST_NUMBER']
          }
        elsif env['CI_NAME'] =~ /DRONE/i
          {
            name:             "drone",
            build_identifier: env['CI_BUILD_NUMBER'],
            build_url:        env['CI_BUILD_URL'],
            branch:           env['CI_BRANCH'],
            commit_sha:       env['CI_BUILD_NUMBER'],
            pull_request:     env['CI_PULL_REQUEST']
          }
        elsif env['CI_NAME'] =~ /codeship/i
          {
            name:             "codeship",
            build_identifier: env['CI_BUILD_NUMBER'],
            build_url:        env['CI_BUILD_URL'],
            branch:           env['CI_BRANCH'],
            commit_sha:       env['CI_COMMIT_ID'],
          }
        elsif env['BUILDBOX']
          {
            name:             "buildbox",
            build_identifier: env['BUILDBOX_JOB_ID'],
            build_url:        env['BUILDBOX_BUILD_URL'],
            branch:           env['BUILDBOX_BRANCH'],
            commit_sha:       env['BUILDBOX_COMMIT']
          }
        else
          {}
        end
      end

    end
  end
end
