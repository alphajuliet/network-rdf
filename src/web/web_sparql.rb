#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "..", "src")
require 'sinatra'
require 'markaby'
require 'sparql_client'
require 'my_prefixes'
require 'json'


def to_json(query_result)
	array = []
	query_result.each_solution do |solution|
		hash = Hash.new
		solution.each_binding { |name, value| hash[name] = value.to_s }
		array << hash
	end
	JSON.pretty_generate(array)
end	

def go(query)
	client = SPARQL::Client.new('http://localhost:8000/sparql/')
	result = client.query(RDF.Prefixes(:sparql) + query)
	if request.accept.include?('text/html')
		markaby :query1, :locals => { :result => result } 
	elsif request.accept.include?('text/json')
		to_json(result)
	end		
end

get '/' do
	markaby :home
end

get '/people/all' do
	query = "
	SELECT ?name ?orgname
	WHERE {
		?m a org:Membership .
		?m org:member [ foaf:name ?name ] .
		?m org:organization [ skos:prefLabel ?orgname ] .
	}
	ORDER BY ?orgname"
	go(query)
end

get '/people/at/:orgname' do
	query = "
	SELECT ?name 
	WHERE {
		?m a org:Membership .
		?m org:organization ?org .
		?org skos:prefLabel \'#{params[:orgname]}\' .
		?m org:member ?p .
		?p foaf:name ?name .
	} 
	ORDER by ?name"
	go(query)
end

get '/person/:name' do
	query = "
	SELECT ?predicate ?object
	WHERE {
		?p foaf:name \'#{params[:name]}\' .
		?p ?predicate ?object .
	}"
	go(query)		
end

get '/no-email' do
	query = "
	SELECT ?name 
	WHERE {
		?card a v:VCard ;
					v:fn ?name .
		OPTIONAL { 
			?card v:email ?e.
		}
		FILTER (!bound(?e))
	}"
	go(query)	
end

get '/foaf-match' do
	query = "
	SELECT ?name ?x ?y
	WHERE {
		?x foaf:name ?name .
		?y foaf:name ?name .
		FILTER (?x < ?y) .
	}"
	go(query)
end

# The End
