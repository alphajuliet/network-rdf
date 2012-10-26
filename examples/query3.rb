#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'sparql-client'
require 'my_prefixes'

# List people that don't have an email address
query = '
SELECT ?name WHERE {
	?card a v:VCard ;
				v:fn ?name .
	OPTIONAL { 
		?card v:email ?e.
	}
	FILTER (!bound(?e))
}
'

s = SparqlClient.new
s.run_query(query, '//sparql:binding/sparql:literal') do |e|
	puts e.text
end

# The End
