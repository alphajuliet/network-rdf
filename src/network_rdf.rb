#!/usr/bin/env ruby

require 'rubygems'
require 'rdf'
require 'rdf/turtle'

class NetworkRDF
	
	attr_reader :graph
	
	def initialize(linkedin)
		@source = linkedin
		@graph = RDF::Graph.new
	end
	
	def add_subject
		ajp = RDF::Vocabulary.new("http://alphajuliet.com/ns/person#")
		p = @source.basic_profile
		name = p['first_name'] + ' ' + p['last_name']
		@graph << [ajp.AndrewJ, RDF.type, RDF::FOAF.Person]
		@graph << [ajp.AndrewJ, RDF::FOAF.name, name]
	end
	
	def to_turtle
		@graph.dump(:turtle)
	end
	
end

# The End
