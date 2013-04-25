#!/usr/bin/env ruby
# Additional RDF prefixes

require 'rubygems'
require 'rdf'

# Extend the namespace
module RDF
	
	PREFIX = {
		:rdf 		=> "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
		:rdfs 	    => "http://www.w3.org/2000/01/rdf-schema#",
		:owl 		=> "http://www.w3.org/2002/07/owl#",
		:xsd 		=> "http://www.w3.org/2001/XMLSchema#",
		
		:foaf 	    => "http://xmlns.com/foaf/0.1/",
		:org		=> "http://www.w3.org/ns/org#",
		:gldp		=> "http://www.w3.org/ns/people#",
		:v			=> "http://www.w3.org/2006/vcard/ns#",
		:db 		=> "http://dbpedia.org/resource/",
		:dbp 		=> "http://dbpedia.org/property/",
		:dbo 		=> "http://dbpedia.org/ontology/",
		:fb			=> "http://rdf.freebase.com/ns/",
		:skos 	    => "http://www.w3.org/2004/02/skos/core#",
		:rel		=> "http://purl.org/vocab/relationship",
		:dct		=> "http://purl.org/dc/terms/",
		
		:net 		=> "http://alphajuliet.com/ns/ont/network#",
		:drink	    => "http://alphajuliet.com/ns/ont/drink#",
		:ajc 		=> "http://alphajuliet.com/ns/contact#",
		:ajp 		=> "http://alphajuliet.com/ns/people#",
		nil			=> "http://alphajuliet.com/ns/contact#"
	}

	#------------------------
	# Shortcut creation method
	def RDF.CreateVocab(prefix)
		RDF::Vocabulary.new(RDF::PREFIX[prefix])
	end
	
	AJP		= RDF.CreateVocab(:ajp)
	AJC 	= RDF.CreateVocab(:ajc)
	NET		= RDF.CreateVocab(:net)
	DRINK	= RDF.CreateVocab(:drink)
	ORG		= RDF.CreateVocab(:org)
	GLDP	= RDF.CreateVocab(:gldp)
	V		= RDF.CreateVocab(:v)
	DB		= RDF.CreateVocab(:db)
	DBP		= RDF.CreateVocab(:dbp)
	DBO		= RDF.CreateVocab(:dbo)
	FB		= RDF.CreateVocab(:fb)
	
	# Save for later
	#REL	= RDF.CreateVocab(:rel)
	
	#------------------------
	# Serialise the prefixes
	def RDF.Prefixes(format=:turtle)
		buffer = []
		RDF::PREFIX.each do |prefix, uri|
			case format
				when :sparql
					buffer << "PREFIX #{prefix.to_s}: <#{uri}>"
				when :turtle
					buffer << "@prefix #{prefix.to_s}: <#{uri}> ."
				else
					buffer << "#{prefix.to_s} #{uri}\n"
			end
		end
		buffer.join("\n")
	end
	
	#------------------------
	# Extend the class
	class Vocabulary
		def self.expand(prefix)
			begin
				RDF::PREFIX[prefix.to_sym]
			rescue
				raise ArgumentError, "#{prefix} not recognised."
			end
		end
		
		def self.expand_curie(curie)
			if (curie =~ /^(\w+):([-_\w]+)/)
				RDF::URI.new(self.expand($1) + $2)
			else
				if (curie =~ /^http/)
					RDF::URI(curie)
				else
					curie
				end
			end
		end
		
	end # class Vocabulary
end # module RDF

# The End
