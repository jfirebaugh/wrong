require "rubygems"
require "bundler"
Bundler.require(:test)

require "minitest/spec"
require "minitest/unit"
require "pp"

# yes, this does look a lot like Wrong::Assert#rescuing :-)
def get_error
  error = nil
  begin
    yield
  rescue Exception, RuntimeError => e
    error = e
  end
  error
end

# dummy class for use by tests
class Color
  attr_reader :name
  def initialize(name)
    @name = name
  end

  def ==(other)
    other.is_a?(Color) && @name == other.name
  end

  def inspect
    "Color:#{@name}"
  end
end

MiniTest::Unit.autorun
