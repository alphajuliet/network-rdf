#!/usr/bin/env ruby

require 'rubygems'
require 'rest-client'
require 'rexml/document'
require 'my_prefixes'

class SparqlClient

	def initialize(endpoint='http://localhost:8000/sparql/')
		@endpoint = endpoint
		@prefixes = RDF.Prefixes(:sparql)
	end
	
	def run_query(query, path, &block)
		puts "POSTing SPARQL query to #{@endpoint}"
		response = RestClient.post @endpoint, :query => (@prefixes.to_s + query)
		puts "Response #{response.code}"
		xml = REXML::Document.new(response.to_str)
		REXML::XPath.each(xml, path, 'sparql' => 'http://www.w3.org/2005/sparql-results#').each do |entry|
			yield(entry)
		end
	end	
		
end

# The End
