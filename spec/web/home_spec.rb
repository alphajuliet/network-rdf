#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "..", "src")
require 'my_prefixes'
require 'web/home'
require 'rack/test'

set :environment, :test

describe 'Home' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "says hello" do
    get '/'
    last_response.should be_ok
  end
  
  it "returns info on a person" do
  	get '/person/Jane%20Smith/card'
  	last_response.should be_ok
  end
end

# The End
