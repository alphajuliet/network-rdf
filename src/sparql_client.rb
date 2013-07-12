#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__))
require 'rdf'
require 'rdf/turtle'
require 'sparql/client'
require 'rest_client'
require 'rexml/document'
require 'my_prefixes'
require 'optparse'
require 'json'
require 'terminal-table'
require 'config'

class SparqlClient

  # Extract the basic SPARQL results
  def SparqlClient.parse_json(json)
    h = JSON.parse(json)
    data = h['results']['bindings']
    {
      :headings => h['head']['vars'], 
      :rows => data.map {|i| i.to_a.map {|x| x[1]['value']}}
    }
  end
	
  # Run a SELECT query
	def SparqlClient.select(query_file, format=:text)
		query = File.open(query_file, "r").read
    store = Configuration.for('rdf_store').store
    response = RestClient.get Configuration.for(store).sparql, 
      :accept => 'application/sparql-results+json', 
      :params => { :query => RDF.Prefixes(:sparql) << query }
		if format == :text
			Terminal::Table.new SparqlClient.parse_json(response)
    else
      response
    end
	end

  # Run a CONSTRUCT query
	def SparqlClient.construct(query_file, format=:turtle)
    store = Configuration.for('rdf_store').store
		client = SPARQL::Client.new(Configuration.for(store).sparql)
		query = File.open(query_file, "r").read
		graph = RDF::Graph.new
		graph << client.query(RDF.Prefixes(:sparql) + query)
		graph.dump(format, :prefixes => RDF::PREFIX)
	end
	
  # Run an INSERT query
	def SparqlClient.insert(triples_file)
    store = Configuration.for('rdf_store').store
		client = SPARQL::Client.new(Configuration.for(store).sparql)
		query = "INSERT DATA { " + File.open(triples_file, "r").read + " }"
		client.query(RDF.Prefixes(:sparql) + "\n" + query)
	end
	
  # Run a CLEAR query
	def SparqlClient.clear(graph="DEFAULT")
    store = Configuration.for('rdf_store').store
		client = SPARQL::Client.new(Configuration.for(store).sparql)
		query = "CLEAR #{graph}"
		client.query(RDF.Prefixes(:sparql) + "\n" + query)
	end
	
end

if __FILE__ == $0
    if ARGV.length < 2
        puts "Usage: #{__FILE__} <command> <file> [<format>]"
        exit -1
    end
    cmd = ARGV[0]
    target = ARGV[1]
    format = ARGV[2] || "text"
    puts SparqlClient.construct(target, format.to_sym) if cmd.downcase == "construct"
    puts SparqlClient.select(target, format.to_sym) if cmd.downcase == "select"
end

# The End
