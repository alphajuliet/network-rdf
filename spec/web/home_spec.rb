#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "..", "src")
require 'my_prefixes'
require 'web/home'
require 'rack/test'
require 'uri'

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
  
  it "returns SPARQL as JSON" do
  	query = 'SELECT ?name ?number WHERE {
			?m a org:Membership ;
				 org:organization [ skos:prefLabel "Oracle Australia" ] ;
				 org:member ?p .
			?p foaf:name ?name ;
				 gldp:card ?c .
			?c v:tel ?t .
			?t a v:cell ;
				 rdf:value ?number .
		}
		ORDER BY ?name
		LIMIT 10'
  	get "/sparql?query=" << URI.escape(query)
  	last_response.should be_ok
  end
end

# The End
