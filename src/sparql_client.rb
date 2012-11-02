#!/usr/bin/env ruby

require 'rubygems'
require 'rdf'
require 'rdf/turtle'
require 'sparql/client'
require 'rexml/document'
require 'my_prefixes'

class SparqlClient

	def initialize(endpoint='http://localhost:8000/sparql/')
		@client = SPARQL::Client.new(endpoint)
		@prefixes = RDF.Prefixes(:sparql)
	end
	
	def SparqlClient.select(query_file)
		client = SPARQL::Client.new('http://localhost:8000/sparql/')
		query = open(query_file).read
		response = client.query(RDF.Prefixes(:sparql) + query)
		response.each_solution do |solution|
			solution.each_binding  { |name, value| puts value.to_s }
		end				
	end

	def SparqlClient.construct(query_file)
		client = SPARQL::Client.new('http://localhost:8000/sparql/')
		query = open(query_file).read
		graph = RDF::Graph.new
		graph = client.query(RDF.Prefixes(:sparql) + query, :content_type => "text/turtle")
		puts graph.dump(:turtle)
	end
	
end

if __FILE__ == $0
	SparqlClient.select(ARGV[0])
end

# The End
