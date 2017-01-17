module RequestsHelper
  def capture_requests(stub)
    requests = []
    stub.to_return { |r| requests << r; {body: "hello"} }
    requests
  end
end

RSpec.configure do |conf|
  conf.include(RequestsHelper)
end
