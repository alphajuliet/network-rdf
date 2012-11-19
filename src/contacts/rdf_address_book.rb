#!/usr/bin/env ruby
# RDF my address book

$:.unshift File.join(File.dirname(__FILE__), "..")
require 'rubygems'
require 'vcard'
require 'rdf'
require 'rdf/turtle'
require 'contacts/rdf_vcard_new'
require 'my_prefixes'

class RDFAddressBook

	attr_reader :graph
	
	#------------------------
	def initialize
		@graph = RDF::Graph.new("http://alphajuliet.com/ns/network-rdf")
	end
	
	def self.new_from_file(filename)
		ab = RDFAddressBook.new
		ab.read_vcards(filename)
		ab
	end
		
	#------------------------
	# Read and convert contents to RDF
	def read_vcards(filename)
		@vcards = Vpim::Vcard.decode(File.open(filename))
	end

	def convert_to_rdf
		@vcards.each do |vcard|
			triples = RDFVCard.new(vcard).to_rdf
			triples.each { |tr| @graph << tr } 
		end
	end
	
	#------------------------
	def to_turtle
		raise "Empty graph" if @graph.nil?
		@graph.dump(:turtle, :prefixes => RDF::PREFIX)
	end
	
	#------------------------
	def write_as_turtle(filename)
		raise "Empty graph" if @graph.nil?
		RDF::Turtle::Writer.open(filename, :prefixes => RDF::PREFIX) do |writer|
			writer << @graph
		end
	end
	
end

# The End
