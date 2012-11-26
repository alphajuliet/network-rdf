#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "src")
require 'rdf'
require 'rdf/turtle'
require 'sparql/client'
require 'rexml/document'
require 'my_prefixes'
require 'optparse'
require 'config'

class SparqlClient
	
	def SparqlClient.select(query_file)
		client = SPARQL::Client.new(MyConfig.get("sparql-endpoint"))
		query = open(query_file).read
		response = client.query(RDF.Prefixes(:sparql) + query)
		response.each_solution do |solution|
			output = []
			solution.each_binding do |name, value|
				p = value.to_s
				p = "<#{p}>" if value.kind_of? RDF::URI
				output << p
			end
			puts output.join(" ")
		end
	end

	def SparqlClient.construct(query_file, format=:turtle)
		client = SPARQL::Client.new(MyConfig.get("sparql-endpoint"))
		query = open(query_file).read
		graph = RDF::Graph.new
		graph << client.query(RDF.Prefixes(:sparql) + query, :content_type => "text/turtle")
		puts graph.dump(format, :prefixes => RDF::PREFIX)
	end
	
	def SparqlClient.insert(triples)
		client = SPARQL::Client.new(MyConfig.get("sparql-endpoint"))
		query = "INSERT DATA { " + triples.to_s + " }"
		client.query(RDF.Prefixes(:sparql) + "\n" + query)
	end
	
	def SparqlClient.clear(graph="DEFAULT")
		client = SPARQL::Client.new(MyConfig.get("sparql-endpoint"))
		query = "CLEAR #{graph}"
		client.query(RDF.Prefixes(:sparql) + "\n" + query)
	end
	
end

=begin
if __FILE__ == $0
	operation = :select
	opts = OptionParser.new
	opts.on("-c", "--construct") { |v| operation = :construct }
	
	fname = opts.parse(*ARGV).first
	SparqlClient.send(operation.to_s, fname)
end
=end

# The End
