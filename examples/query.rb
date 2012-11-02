#!/usr/bin/env ruby
# Test SPARQL requests to 4store

$:.unshift File.join(File.dirname(__FILE__), "..", "src")

require 'sparql_client'

# List the first 10 people that work for Oracle Australia, and their mobile number
query = '
SELECT ?name ?number WHERE {
  ?m a org:Membership ;
		 org:organization [ skos:prefLabel "Oracle Australia" ] ;
	   org:member ?p .
	?p foaf:name ?name ;
	   gldp:card ?c .
	?c v:tel ?t .
	?t a v:cell ;
	   rdf:value ?number .
}
ORDER BY ?name
LIMIT 10'

s = SparqlClient.new
s.run_query(query, '//sparql:binding/sparql:literal') do |e|
	puts e.text
end

# The End
