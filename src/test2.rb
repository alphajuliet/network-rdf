#!/usr/bin/env ruby
# Test SPARQL requests to 4store

require 'rubygems'
require 'rest_client'
require 'rexml/document'

query = <<EOT
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT ?n WHERE {
 ?s a foaf:person .
 ?a foaf:name ?n .
} 
ORDER BY ?n
LIMIT 10
EOT
endpoint = 'http://localhost:8000/sparql/'

puts "POSTing SPARQL query to #{endpoint}"
response = RestClient.post endpoint, :query => query
puts "Response #{response.code}"
xml = REXML::Document.new(response.to_str)
REXML::XPath.each(xml, 
	'//sparql:binding[@name="n"]/sparql:literal', 
	'sparql' => 'http://www.w3.org/2005/sparql-results#').each do |name|
	puts name.text
end

# The End
