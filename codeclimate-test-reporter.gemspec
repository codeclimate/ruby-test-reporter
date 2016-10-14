require "./lib/code_climate/test_reporter/version"

Gem::Specification.new do |spec|
  spec.name = "codeclimate-test-reporter"
  spec.version = CodeClimate::TestReporter::VERSION
  spec.authors = ["Bryan Helmkamp"]
  spec.email = ["bryan@brynary.com"]
  spec.description = "Collects test coverage data from your Ruby test suite and sends it to Code Climate's hosted, automated code review service. Based on SimpleCov."
  spec.summary = "Uploads Ruby test coverage data to Code Climate."
  spec.homepage = "https://github.com/codeclimate/ruby-test-reporter"
  spec.license = "MIT"

  spec.files = `git ls-files bin lib config LICENSE.txt README.md`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.required_ruby_version = ">= 1.9"

  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "json", "~> 1.8", "< 2"
end
