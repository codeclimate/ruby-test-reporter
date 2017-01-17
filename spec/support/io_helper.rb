module IOHelper
  def capture_io
    stdout = $stdout
    stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new

    yield if block_given?

    [$stdout, $stderr]
  ensure
    $stdout = stdout
    $stderr = stderr
  end
end

RSpec.configure do |conf|
  conf.include(IOHelper)
end
