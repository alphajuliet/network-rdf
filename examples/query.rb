#!/usr/bin/env ruby
# Test SPARQL requests to 4store

require 'rubygems'
require 'rest_client'
require 'rexml/document'

prefixes = "
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX gldp: <http://www.w3.org/ns/people#>
PREFIX org: <http://www.w3.org/ns/org#>
PREFIX v: <http://www.w3.org/2006/vcard/ns#>
"

# Retrieve the first 10 names
query1 = "
SELECT ?n WHERE {
 ?s a foaf:Person .
 ?a foaf:name ?n .
} 
ORDER BY ?n
LIMIT 10"

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

query = query4

endpoint = 'http://localhost:8000/sparql/'

puts "POSTing SPARQL query to #{endpoint}"
response = RestClient.post endpoint, :query => (prefixes << query)
puts "Response #{response.code}"
xml = REXML::Document.new(response.to_str)
REXML::XPath.each(xml, '//sparql:binding/sparql:literal', 
	'sparql' => 'http://www.w3.org/2005/sparql-results#').each do |entry|
	puts entry.text
end

# The End
