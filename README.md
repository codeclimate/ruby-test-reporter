# codeclimate-test-reporter

[![Code Climate](https://codeclimate.com/github/codeclimate/ruby-test-reporter/badges/gpa.svg)](https://codeclimate.com/github/codeclimate/ruby-test-reporter)

Posts SimpleCov test coverage data from your Ruby test suite to Code Climate's hosted, automated code review service.

Code Climate - [https://codeclimate.com](https://codeclimate.com)

## Installation

This gem requires a user, but not necessarily a paid account, on Code Climate, so if you don't have one the
first step is to signup at: [https://codeclimate.com](https://codeclimate.com). Then:

1. Add this to your Gemfile:

        gem "codeclimate-test-reporter", group: :test

1. Start SimpleCov as you normally would (more information here: https://github.com/colszowka/simplecov)

1. Set the `CODECLIMATE_REPO_TOKEN` environment variable (provided after you add your repo to your Code Climate account by clicking on "Setup Test Coverage" on the right hand side of your feed)

1. Run the `codeclimate-test-reporter` executable at the end of your test suite

Please contact hello@codeclimate.com if you need any assistance setting this up.

## Troubleshooting / FYIs

Across the many different testing frameworks, setups, and environments, there are lots of variables at play. If you're having any trouble with your test coverage reporting or the results are confusing, please see our full documentation here: https://docs.codeclimate.com/docs/setting-up-test-coverage

## Contributions

Patches, bug fixes, feature requests, and pull requests are welcome on the
GitHub page for this project: [https://github.com/codeclimate/ruby-test-reporter](https://github.com/codeclimate/ruby-test-reporter)

This gem is maintained by Bryan Helmkamp (bryan@codeclimate.com).

## Copyright

See LICENSE.txt

Portions of the implementation were inspired by the coveralls-ruby gem.
