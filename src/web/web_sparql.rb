#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "..", "src")
require 'sinatra'
require 'markaby'
require 'sparql_client'
require 'my_prefixes'

get '/' do
	'Hello, world!'
end

get '/people_at/:orgname' do
	query = "
		SELECT ?name ?number WHERE {
			?m a org:Membership .
			?m org:organization ?org .
			?org skos:prefLabel \'#{params[:orgname]}\' .
			?m org:member ?p .
			?p foaf:name ?name .
			?p gldp:card ?c .
			?c v:tel ?t .
			?t a v:cell .
			?t rdf:value ?number .
		} 
		ORDER by ?name"
	client = SPARQL::Client.new('http://localhost:8000/sparql/')
	response = client.query(RDF.Prefixes(:sparql) + query)
	markaby :query1, :locals => { :response => response }
	
end

# The End
