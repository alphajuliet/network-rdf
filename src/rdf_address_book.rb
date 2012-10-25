#!/usr/bin/env ruby
# RDF my address book

require 'rubygems'
require 'vpim/vcard'
require 'rdf'
require 'rdf/turtle'
require 'rdf_vcard'

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
			triples.each { |t| @graph << t } 
		end
	end
	
	#------------------------
	def to_turtle
		raise "Empty graph" if @graph.nil?
		@graph.dump(:turtle)
	end
	
	#------------------------
	def write_as_turtle(filename)
		raise "Empty graph" if @graph.nil?
		RDF::Turtle::Writer.open(filename) do |writer|
			writer << @graph
		end
	end
	
end

# The End
