#!/usr/bin/env ruby
# Additional RDF prefixes

require 'rubygems'
require 'rdf'
module RDF
	AJP 	= RDF::Vocabulary.new("http://alphajuliet.com/ns/person#")
	AJO 	= RDF::Vocabulary.new("http://alphajuliet.com/ns/org#")
	ORG 	= RDF::Vocabulary.new("http://www.w3.org/ns/org#")
	GLDP 	= RDF::Vocabulary.new("http://www.w3.org/ns/people#")
	V 		= RDF::Vocabulary.new("http://www.w3.org/2006/vcard/ns#")
	REL 	= RDF::Vocabulary.new("http://purl.org/vocab/relationship")
end
	
# The End
