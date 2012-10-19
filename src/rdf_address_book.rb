#!/usr/bin/env ruby
# RDF address book

require 'rubygems'
require 'vpim/vcard'
require 'rdf'

# Turn an array of labels and items into a hash
def create_hash(labels, items)
	raise ArgumentError, "arrays not the same length: #{labels.length} vs #{items.length}" if (labels.length != items.length)
	h = Hash.new
	labels.each_index do |i|
		sym = labels[i].tr(' ', '_').downcase.to_sym
		h[sym] = items.at(i)
	end
end

class RDFAddressBook

	attr_reader :graph
	
	def initialize
		@graph = RDF::Graph.new
	end
	
	# Read and convert to RDF
	def read_vcards(filename)
		vcards = Vpim::Vcard.decode(File.open(filename))
		vcards.each { |contact| process(contact) }
	end
	
	# Process each VCard
	def process(contact)		
		ajp = RDF::Vocabulary.new("http://alphajuliet.com/ns/people#")
		if contact.name.given.empty?
			# We have an organisation. Ignore for now
			
		else # We have a person
			id = (contact.name.fullname).downcase.tr(' &', '-')
			@graph << [ ajp[id], RDF[:type], RDF::FOAF.person ]
		end
		
	end
	
end

# The End
