module FixtureHelper
  # Unpack the git project at spec/fixtures/{name}.tar.gz and run the block
  # within it, presumably formatting a simplecov result.
  def within_repository(name)
    old_pwd = Dir.pwd
    FileUtils.cd("spec/fixtures")
    system("tar -xzf #{name}.tar.gz >/dev/null") or
      raise ArgumentError, "could not extract #{name}.tar.gz"
    FileUtils.cd(name)
    yield
  ensure
    FileUtils.cd(old_pwd)
    FileUtils.rm_rf("spec/fixtures/#{name}")
  end

  # Load spec/fixtures/{name}_resultset.json and correct the file paths,
  # stripping the given prefix and pre-pending the fixture project's directory.
  def load_resultset(name, project_prefix)
    fixture = File.join("spec", "fixtures", "#{name}_resultset.json")
    fixture_result = JSON.parse(File.read(fixture))
    updated_prefix = "#{SimpleCov.root}/spec/fixtures/#{name}/"
    update_source_paths(fixture_result, project_prefix, updated_prefix)
  end

  # :private: actual munging of the simplecov nest hash
  def update_source_paths(fixture_result, from, to)
    fixture_result.each_with_object({}) do |(name, values), out|
      out[name] = {}
      values.each do |k, v|
        if k == "coverage"
          out[name][k] = {}
          v.each do |p, lines|
            path = p.sub(from, to)
            out[name][k][path] = lines
          end
        else
          out[name][k] = v
        end
      end
    end
  end
end

RSpec.configure do |conf|
  conf.include(FixtureHelper)
end
