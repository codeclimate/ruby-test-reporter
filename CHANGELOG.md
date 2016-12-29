# Change log

## master (unreleased)

### New features

### Bug fixes

### Changes

### v1.0.4 (2016-12-29)

### New features

* Accept path to coverage results as optional first argument ([@jreinert](https://github.com/codeclimate/ruby-test-reporter/pull/158))

### Bug fixes

* Handle multi-command resultsets ([@pbrisbin](https://github.com/codeclimate/ruby-test-reporter/pull/163))

## v1.0.3 (2016-11-09)

### Bug fixes

* Improve strategy for Ruby 1.9.3 compatibility testing

## v1.0.2 (2016-11-08)

### Bug fixes

* Fixed crashing error when the path to a file in the coverage report
  contains a parenthesis.

## v1.0.1 (2016-11-06)

### Bug fixes

* Made sure the gem can be built while running Ruby 1.9.3

## v1.0.0 (2016-11-03)

### Changes

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

## v0.6.0 (2016-06-27)

### New features

* Support `ENV["SSL_CERT_PATH"]` for custom SSL certificates
