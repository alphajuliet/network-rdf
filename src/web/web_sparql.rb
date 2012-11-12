#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "..", "src")
require 'sinatra'
require 'markaby'
require 'sparql_client'
require 'my_prefixes'
require 'json'

# Convert a solution to JSON format
def to_json(query_result)
	array = []
	query_result.each_solution do |solution|
		hash = Hash.new
		solution.each_binding { |name, value| hash[name] = value.to_s }
		array << hash
	end
	JSON.pretty_generate(array)
end	

# Do the SPARQL query and render on the given template, or return as JSON
def query(template=:query1, &block)
	client = SPARQL::Client.new('http://localhost:8000/sparql/')
	query = yield
	result = client.query(RDF.Prefixes(:sparql) + query)
	if request.accept.include?('text/html')
		markaby template, :locals => { :result => result } 
	elsif request.accept.include?('application/json')
		to_json(result)
	end		
end

get '/' do
	markaby :home
end

get '/people/all' do
	query do
		"SELECT ?name ?orgname
		WHERE {
			?m a org:Membership .
			?m org:member [ foaf:name ?name ] .
			?m org:organization [ skos:prefLabel ?orgname ] .
		}
		ORDER BY ?orgname"
	end
end

get '/people/at/:orgname' do
	query do 
		"SELECT ?name 
		WHERE {
		?m a org:Membership .
		?m org:organization ?org .
		?org skos:prefLabel \'#{params[:orgname]}\' .
		?m org:member ?p .
		?p foaf:name ?name .
		} 
		ORDER by ?name"
	end
end

get '/person/:name' do
	query do
		"SELECT ?predicate ?object
		WHERE {
			?p foaf:name \'#{params[:name]}\' .
			?p ?predicate ?object .
		}"
	end
end

get '/org/count_by_person' do
	min = params["min"] || 0;
	query do
		"SELECT ?orgname (COUNT (?p) AS ?members)
		WHERE {
			?m a org:Membership .
			?m org:organization ?org .
			?org skos:prefLabel ?orgname .
			?m org:member ?p .
		}
		GROUP BY ?orgname
		HAVING (COUNT (?p) >= #{min})
		ORDER BY DESC(?members)"
	end
end

get '/no-email' do
	query do
		"SELECT ?name 
		WHERE {
			?card a v:VCard ;
						v:fn ?name .
			OPTIONAL { 
				?card v:email ?e.
			}
			FILTER (!bound(?e))
		}"
	end
end

get '/viz' do
	markaby :viz 
end

# The End
