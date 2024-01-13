require './lilipad/logger.rb'
require 'sinatra'

configure { set :server, :puma }

class Foo
  def initialize(bar)
    @bar = bar
  end

  def bar_and_one
    y = @bar

    add_one(y)
  end

  private

  def add_one(x)
    x + 1
  end
end

include Lilipad::Logger

get '/' do
  Foo.new(1).bar_and_one

  "hello world"
end







