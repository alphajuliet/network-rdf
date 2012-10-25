#!/usr/bin/env ruby
# Test SPARQL requests to 4store

require 'rubygems'
require 'rdf'
require 'rest-client'
require 'rexml/document'
require 'sparql/client'

module RDF
	AJP = RDF::Vocabulary.new("http://alphajuliet.com/ns/person#")
	AJO = RDF::Vocabulary.new("http://alphajuliet.com/ns/org#")
	ORG = RDF::Vocabulary.new("http://www.w3.org/ns/org#")
	GLDP = RDF::Vocabulary.new("http://www.w3.org/ns/people#")
	V = RDF::Vocabulary.new("http://www.w3.org/2006/vcard/ns#")
end

# SPARQL query using Ruby client
@sparql = SPARQL::Client.new('http://localhost:8000/sparql/')
def query1
	pattern = [:p, RDF::FOAF[:name], :n]
	query = @sparql.select(:n).where(pattern).limit(10)
	query.each_solution do |solution|
		puts solution.n.to_s
	end
end


# Queries using real SPARQL and XML
class Sparql

	def initialize(endpoint='http://localhost:8000/sparql/')
		@endpoint = endpoint
		@prefixes = "
			PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			PREFIX skos: <http://www.w3.org/2004/02/skos/core>
			PREFIX foaf: <http://xmlns.com/foaf/0.1/>
			PREFIX gldp: <http://www.w3.org/ns/people#>
			PREFIX org: <http://www.w3.org/ns/org#>
			PREFIX v: <http://www.w3.org/2006/vcard/ns#>"
	end
	
	def run_query(query, path, &block)
		puts "POSTing SPARQL query to #{@endpoint}"
		response = RestClient.post @endpoint, :query => (@prefixes << query)
		puts "Response #{response.code}"
		xml = REXML::Document.new(response.to_str)
		REXML::XPath.each(xml, path, 'sparql' => 'http://www.w3.org/2005/sparql-results#').each do |entry|
			yield(entry)
		end
	end	
	
end


# List the first 10 people that work for Oracle Australia and their mobile number
query2 = '
SELECT ?name ?number WHERE {
  ?m a org:Membership ;
		 org:organization [ rdfs:label "Oracle Australia" ] ;
	   org:member ?p .
	?p foaf:name ?name ;
	   gldp:card ?c .
	?c v:tel ?tel .
	?tel a v:cell ;
	     rdf:value ?number .
}
ORDER BY ?name
LIMIT 10'

# List people that don't have an email address
query3 = '
SELECT ?name WHERE {
	?card a v:VCard ;
        v:fn ?name .
	OPTIONAL { 
		?card v:email ?e.
	}
	FILTER (!bound(?e))
}'

query4 = '
SELECT DISTINCT ?orgname WHERE {
	?m org:organization [ rdfs:label ?orgname ] .
}
ORDER by ?orgname'

s = Sparql.new
s.run_query(query3, '//sparql:binding/sparql:literal') do |e|
	puts e.text
end


# The End
