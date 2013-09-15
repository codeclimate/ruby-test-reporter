# codeclimate-test-reporter

Collects test coverage data from your Ruby test suite and sends it to Code
Climate's hosted, automated code review service. Based on SimpleCov.

Code Climate - [https://codeclimate.com](https://codeclimate.com)

## Installation

This gem only works with Code Climate accounts, so if you don't have one the
first step is to create an account at: [https://codeclimate.com](https://codeclimate.com). Then:

1. Add this to your Gemfile:

        gem install "codeclimate-test-reporter", group: :test

1. Start the test reporter **at the very beginning** of your `test_helper.rb` or
  `spec_helper.rb` file:

        require "codeclimate-test-reporter"
        CodeClimate::TestReporter.start

Then set the `CODECLIMATE_REPO_TOKEN` environment variable when you run your build
on your CI server, and the results will show up in your Code Climate account.

The `CODECLIMATE_REPO_TOKEN` value is provided after you add your repo to your
Code Climate account if you are in the test coverage private beta.

Please contact hello@codeclimate.com if you need any assistance setting this up.

## Help! Your gem is raising a ...

### VCR::Errors::UnhandledHTTPRequestError

Add the following to your spec or test helper:

        VCR.configure do |config|
          # your existing configuration
          config.ignore_hosts 'codeclimate.com'
        end

### WebMock::NetConnectNotAllowedError

Add the following to your spec or test helper:

        WebMock.disable_net_connect!(:allow => "codeclimate.com")

### Other communication failures

If you are using a web stubbing library similar to VCR or WebMock which prevent external requests during test runs, you will need configure these libraries to allow Code Climate to make external requests.

## Contributions

Patches, bug fixes, feature requests, and pull requests are welcome on the
GitHub page for this project: [https://github.com/codeclimate/ruby-test-reporter](https://github.com/codeclimate/ruby-test-reporter)

This gem is maintained by Bryan Helmkamp (bryan@codeclimate.com).

## Copyright

See LICENSE.txt

Portions of the implementation were inspired by the coveralls-ruby gem.
