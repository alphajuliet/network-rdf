#!/usr/bin/env ruby

require 'rubygems'
require 'rest-client'
require 'rexml/document'

class SparqlClient

	def initialize(endpoint='http://localhost:8000/sparql/')
		@endpoint = endpoint
		@prefixes = "
			PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
			PREFIX foaf: <http://xmlns.com/foaf/0.1/>
			PREFIX gldp: <http://www.w3.org/ns/people#>
			PREFIX org: <http://www.w3.org/ns/org#>
			PREFIX v: <http://www.w3.org/2006/vcard/ns#>
			PREFIX ajp: <http://alphajuliet.com/ns/person#>
			PREFIX ajo: <http://alphajuliet.com/ns/org#>
			"
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

# The End
