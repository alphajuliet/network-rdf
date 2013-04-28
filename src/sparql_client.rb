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
        store = Configuration.for('rdf_store').store
		client = SPARQL::Client.new(Configuration.for(store).sparql)
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
        store = Configuration.for('rdf_store').store
		client = SPARQL::Client.new(Configuration.for(store).sparql)
		query = File.open(query_file, "r").read
		graph = RDF::Graph.new
		graph << client.query(RDF.Prefixes(:sparql) + query)
		graph.dump(format, :prefixes => RDF::PREFIX)
	end
	
	def SparqlClient.insert(triples_file)
        store = Configuration.for('rdf_store').store
		client = SPARQL::Client.new(Configuration.for(store).sparql)
		query = "INSERT DATA { " + File.open(triples_file, "r").read + " }"
		client.query(RDF.Prefixes(:sparql) + "\n" + query)
	end
	
	def SparqlClient.clear(graph="DEFAULT")
        store = Configuration.for('rdf_store').store
		client = SPARQL::Client.new(Configuration.for(store).sparql)
		query = "CLEAR #{graph}"
		client.query(RDF.Prefixes(:sparql) + "\n" + query)
	end
	
end

if __FILE__ == $0
    if ARGV.length != 2
        puts "Usage: #{__FILE__} <command> <file>"
        exit -1
    end
    cmd = ARGV[0]
    target = ARGV[1]
    puts SparqlClient.construct(target) if cmd.downcase == "construct"
    puts SparqlClient.select(target) if cmd.downcase == "select"
end

# The End
