module CodeClimate
  module TestReporter
    class Ci

      def self.service_data
        if ENV['TRAVIS']
          {
            name:             "travis-ci",
            branch:           ENV['TRAVIS_BRANCH'],
            build_identifier: ENV['TRAVIS_JOB_ID'],
            pull_request:     ENV['TRAVIS_PULL_REQUEST']
          }
        elsif ENV['CIRCLECI']
          {
            name:             "circlci",
            build_identifier: ENV['CIRCLE_BUILD_NUM'],
            branch:           ENV['CIRCLE_BRANCH'],
            commit_sha:       ENV['CIRCLE_SHA1']
          }
        elsif ENV['SEMAPHORE']
          {
            name:             "semaphore",
            branch:           ENV['BRANCH_NAME'],
            build_identifier: ENV['SEMAPHORE_BUILD_NUMBER']
          }
        elsif ENV['JENKINS_URL']
          {
            name:             "jenkins",
            build_identifier: ENV['BUILD_NUMBER'],
            build_url:        ENV['BUILD_URL'],
            branch:           ENV['GIT_BRANCH'],
            commit_sha:       ENV['GIT_COMMIT']
          }
        elsif ENV['TDDIUM']
          {
            name:             "tddium",
            build_identifier: ENV['TDDIUM_SESSION_ID'],
            worker_id:        ENV['TDDIUM_TID']
          }
        elsif ENV['CI_NAME'] =~ /codeship/i
          {
            name:             "codeship",
            build_identifier: ENV['CI_BUILD_NUMBER'],
            build_url:        ENV['CI_BUILD_URL'],
            branch:           ENV['CI_BRANCH'],
            commit_sha:       ENV['CI_COMMIT_ID'],
          }
        else
          {}
        end
      end

    end
  end
end
