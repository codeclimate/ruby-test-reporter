require 'spec_helper'
require 'foo'

describe CodeClimate::TestReporter do
  it "works" do
    3.times { Foo.new.add }
  end
end
