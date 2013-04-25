#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__))
require 'rdf'
require 'rdf/turtle'
require 'sparql/client'
require 'rexml/document'
require 'my_prefixes'
require 'optparse'
require 'terminal-table'
require 'config'

class SparqlClient
	
	def SparqlClient.select(query_file)
		client = SPARQL::Client.new(MyConfig.get["dydra"]["sparql"])
		query = File.open(query_file, "r").read
		response = client.query(RDF.Prefixes(:sparql) + query)
		output = []
		header = response.variable_names
		response.each_solution do |solution|
			row = []
			solution.each_binding do |name, value|
				p = value.to_s
				p = "<#{p}>" if value.kind_of? RDF::URI
				row << p
			end
			output << row
		end
		Terminal::Table.new :headings => header, :rows => output
	end

	def SparqlClient.construct(query_file, format=:turtle)
		client = SPARQL::Client.new(MyConfig.get["dydra"]["sparql"])
		query = File.open(query_file, "r").read
		graph = RDF::Graph.new
		graph << client.query(RDF.Prefixes(:sparql) + query, :content_type => "text/turtle")
		graph.dump(format, :prefixes => RDF::PREFIX)
	end
	
	def SparqlClient.insert(triples_file)
		client = SPARQL::Client.new(MyConfig.get["dydra"]["sparql"])
		query = "INSERT DATA { " + File.open(triples_file, "r").read + " }"
		client.query(RDF.Prefixes(:sparql) + "\n" + query)
	end
	
	def SparqlClient.clear(graph="DEFAULT")
		client = SPARQL::Client.new(MyConfig.get["dydra"]["sparql"])
		query = "CLEAR #{graph}"
		client.query(RDF.Prefixes(:sparql) + "\n" + query)
	end
	
end

if __FILE__ == $0
	opts = OptionParser.new
	opts.on("-c", "--construct QUERY_FILE", String) { |v| puts SparqlClient.construct(fname) }
	opts.on("-s", "--select QUERY_FILE", String) 		{ |v| puts SparqlClient.select(fname) }
	opts.on("-i", "--insert TRIPLES_FILE", String) 	{ |v| SparqlClient.insert(fname) }
	opts.on("-x", "--clear GRAPH", String)	 				{ |v| SparqlClient.clear(graph) }
end

# The End
