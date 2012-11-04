#!/usr/bin/env ruby

require 'rdf'
require 'rdf/turtle'
require 'sparql/client'
require 'rexml/document'
require 'my_prefixes'
require 'optparse'

class SparqlClient

	def initialize(endpoint='http://localhost:8000/sparql/')
		@client = SPARQL::Client.new(endpoint)
		@prefixes = RDF.Prefixes(:sparql)
	end
	
	def SparqlClient.select(query_file, format=:turtle)
		client = SPARQL::Client.new('http://localhost:8000/sparql/')
		query = open(query_file).read
		response = client.query(RDF.Prefixes(:sparql) + query)
		output = []
		response.each_solution do |solution|
			solution.each_binding  { |name, value| output << value.to_s }
		end				
		output.join("\n")
	end

	def SparqlClient.construct(query_file, format=:turtle)
		client = SPARQL::Client.new('http://localhost:8000/sparql/')
		query = open(query_file).read
		graph = RDF::Graph.new
		graph << client.query(RDF.Prefixes(:sparql) + query, :content_type => "text/turtle")
		puts graph.dump(format, :prefixes => RDF::PREFIX)
	end
	
end

if __FILE__ == $0
	operation = :select
	opts = OptionParser.new
	opts.on("-c", "--construct") { |v| operation = :construct }
	
	fname = opts.parse(*ARGV).first
	SparqlClient.send(operation.to_s, fname)
end

# The End
