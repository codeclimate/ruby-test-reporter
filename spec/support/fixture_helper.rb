module FixtureHelper
  # Unpack the git project at spec/fixtures/{name}.tar.gz and run the block
  # within it, presumably formatting a simplecov result.
  def within_repository(name)
    old_pwd = Dir.pwd
    FileUtils.cd("spec/fixtures")
    system("tar -xvzf #{name}.tar.gz >/dev/null") or
      raise ArgumentError, "could not extract #{name}.tar.gz"
    FileUtils.cd(name)
    yield
  ensure
    FileUtils.cd(old_pwd)
    FileUtils.rm_rf("spec/fixtures/#{name}")
  end
end

RSpec.configure do |conf|
  conf.include(FixtureHelper)
end
