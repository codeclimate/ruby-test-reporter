# codeclimate-test-reporter

[![Code Climate](https://codeclimate.com/github/codeclimate/ruby-test-reporter/badges/gpa.svg)](https://codeclimate.com/github/codeclimate/ruby-test-reporter)

Posts SimpleCov test coverage data from your Ruby test suite to Code Climate's
hosted, automated code review service.

Code Climate - [https://codeclimate.com](https://codeclimate.com)

## Installation

This gem requires a user, but not necessarily a paid account, on Code Climate,
so if you don't have one the first step is to signup at:
[https://codeclimate.com](https://codeclimate.com). Then follow the
instructions on our [documentation site](https://docs.codeclimate.com/docs/ruby)

Please contact hello@codeclimate.com if you need any assistance setting this up.

## Troubleshooting / FYIs

Across the many different testing frameworks, setups, and environments, there
are lots of variables at play. If you're having any trouble with your test
coverage reporting or the results are confusing, please see our full
documentation here: https://docs.codeclimate.com/docs/setting-up-test-coverage

## Upgrading from pre-1.0 Versions

Version `1.0` of the this gem introduces new, breaking changes to the way the
test reporter is meant to be executed. The following list summarizes the major
differences:

* Previously, this gem extended `Simplecov` with a custom formatter which posted
  results to Code Climate. Now, you are responsible for executing `Simplecov`
  yourself.

  * If you already have the following in your test/test_helper.rb
    (or spec_helper.rb, cucumber env.rb, etc)

    ```ruby
    require 'codeclimate-test-reporter'
    CodeClimate::TestReporter.start
    ```

    then you should replace it with

    ```ruby
    require 'simplecov'
    SimpleCov.start
    ```

* Previously, the `codeclimate-test-reporter` automatically uploaded results at
  the end of your test suite.  Now, you are responsible for running
  `codeclimate-test-reporter` as a separate step in your build.
* Previously, this gem added some exclusion rules tuned according to feedback
  from its users, and now these no longer happen automatically. *If you are
  experiencing a discrepancy in test coverage % after switching to the new gem
  version, it may be due to missing exclusions. Filtering `vendor`, `spec`, or
  `test` directories may fix this issue.*
* Previously, during the execution of multiple test suites, this gem would send
  results from the first suite completed. You are now expected to run an
  executable packaged with this gem as a separate build step, which means that
  whatever results are there (likely the results from the last suite) will be
  posted to Code Climate.

## Contributions

Patches, bug fixes, feature requests, and pull requests are welcome on the
GitHub page for this project:
[https://github.com/codeclimate/ruby-test-reporter](https://github.com/codeclimate/ruby-test-reporter)

This gem is maintained by Bryan Helmkamp (bryan@codeclimate.com).

## Copyright

See LICENSE.txt

Portions of the implementation were inspired by the coveralls-ruby gem.
