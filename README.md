# codeclimate-test-reporter

[![Code Climate](https://codeclimate.com/github/codeclimate/ruby-test-reporter/badges/gpa.svg)](https://codeclimate.com/github/codeclimate/ruby-test-reporter)

Collects test coverage data from your Ruby test suite and sends it to Code
Climate's hosted, automated code review service. Based on SimpleCov.

Code Climate - [https://codeclimate.com](https://codeclimate.com)

## Installation

This gem requires a user, but not necessarily a paid account, on Code Climate, so if you don't have one the
first step is to signup at: [https://codeclimate.com](https://codeclimate.com). Then:

1. Add this to your Gemfile:

        gem "codeclimate-test-reporter", group: :test

1. Start the test reporter **on the very first line** of your `test_helper.rb` or
  `spec_helper.rb` file:

        require "codeclimate-test-reporter"
        CodeClimate::TestReporter.start

Then set the `CODECLIMATE_REPO_TOKEN` environment variable when you run your build
on your CI server, and the results will show up in your Code Climate account.

The `CODECLIMATE_REPO_TOKEN` value is provided after you add your repo to your
Code Climate account by clicking on "Setup Test Coverage" on the right hand side of your feed.

Please contact hello@codeclimate.com if you need any assistance setting this up.

## Configuration

Certain behaviors of the test reporter can be configured. See the `Configuration`
class for more details. For example, you can change the logging level to not
print info messages:

*Note that the configuration block must come before TestReporter.start.*

```ruby
CodeClimate::TestReporter.configure do |config|
  config.logger.level = Logger::WARN
end

CodeClimate::TestReporter.start
```

Another example for when your Rails application root is not at the root of the git repository root

```ruby
CodeClimate::TestReporter.configure do |config|
  config.path_prefix = "app_root" #the root of your Rails application relative to the repository root
  config.git_dir = "../" #the relative or absolute location of your git root compared to where your tests are run
end

CodeClimate::TestReporter.start
```

## Extending Simplecov with other formatters

Since ruby-test-reporter 0.4.0 you can use `CodeClimate::TestReporter::Formatter` as a Simplecov formatter directly. Just add the formatter to your Simplecov formatter in addition to the rest of your configuration:

```ruby
require 'codeclimate-test-reporter'
SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    CodeClimate::TestReporter::Formatter
  ]
  ...
end
```

## Using with [parallel_tests](https://github.com/grosser/parallel_tests)

Note: This may work with other parallel test runners as long as they run on the same machine.

Be sure you're using `simplecov` `>= 0.9.0`. 

Add the following to your `test_helper.rb`/`spec_helper.rb` instead of what is normally required.

```ruby
require 'simplecov'
require 'codeclimate-test-reporter'
SimpleCov.add_filter 'vendor'
SimpleCov.formatters = []
SimpleCov.start CodeClimate::TestReporter.configuration.profile
```

Then after all your tests run, in a rake task or as a build step do:

```
require 'simplecov'
require 'codeclimate-test-reporter'
CodeClimate::TestReporter::Formatter.new.format(SimpleCov.result)
```

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
