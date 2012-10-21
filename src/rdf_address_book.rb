#!/usr/bin/env ruby
# RDF my address book

require 'rubygems'
require 'vpim/vcard'
require 'rdf'
require 'rdf/turtle'
require 'uuid'

class RDFAddressBook

	attr_reader :graph
	
	#------------------------
	def initialize
		define_prefixes
		@graph = RDF::Graph.new("http://alphajuliet.com/ns/network-rdf")
	end
	
	def self.new_from_file(filename)
		ab = RDFAddressBook.new
		ab.read_vcards(filename)
		ab.convert_to_rdf
		ab
	end
	
	#------------------------
	def define_prefixes
		@ajp = RDF::Vocabulary.new("http://alphajuliet.com/ns/person#")
		@ajo = RDF::Vocabulary.new("http://alphajuliet.com/ns/org#")
		@ajx = RDF::Vocabulary.new("http://alphajuliet.com/ns/org#")		
		@org = RDF::Vocabulary.new("http://www.w3.org/ns/org#")
		@gldp = RDF::Vocabulary.new("http://www.w3.org/ns/people#")
		@v = RDF::Vocabulary.new("http://www.w3.org/2006/vcard/ns#")		
	end
	
	#------------------------
	# Read and convert to RDF
	def read_vcards(filename)
		@vcards = Vpim::Vcard.decode(File.open(filename))
	end

	def convert_to_rdf
		@vcards.each do |contact| 
			process(contact)
		end
	end
	
	#------------------------
	# Process each VCard
	def process(contact)		
		if contact.name.given.empty?
			create_organisation(contact)
		else
			add_person(contact)
		end
	end
	
	#------------------------

	def add_person(vcard)
		# id = (vcard.name.fullname).downcase.tr(' ', '-').tr("'&", "")
		id = vcard.values("X-ABUID").first
		person = @ajp[id]

		@graph << [person, RDF[:type], RDF::FOAF[:Person]]
		@graph << [person, RDF::FOAF[:name], vcard.name.fullname]
		@graph << [person, RDF::SKOS[:prefName], vcard.name.fullname]
		
		add_card(person, vcard)
		add_organisation(person, vcard)
		add_social_profiles(person, vcard)
		
	end
	
	#------------------------
	def add_card(target, vcard)
		card = RDF::Node.new
		@graph << [target, @gldp[:card], card]
		@graph << [card, RDF[:type], @v[:VCard]]
		@graph << [card, @v[:fn], vcard.name.fullname]		

		add_emails(card, vcard)
		add_telephones(card, vcard)
		add_addresses(card, vcard)	
	end	
	
	#------------------------
	def add_emails(target, vcard)
		vcard.emails.each do |e|
			email = RDF::Node.new
			@graph << [target, @v[:email], email]
			@graph << [email, RDF[:type], @v[e.location.first]]
			@graph << [email, RDF[:value], e.to_s]
		end		
	end
	
	#------------------------
	def add_telephones(target, vcard)
		vcard.telephones.each do |t|
			tel = RDF::Node.new
			@graph << [target, @v[:tel], tel]
			@graph << [tel, RDF[:type], @v[t.location.first]]
			@graph << [tel, RDF[:value], t.to_s]
		end		
	end
	
	#------------------------
	def add_addresses(target, vcard)
		vcard.addresses.each do |a|
			unless a.locality.nil?
				adrs = RDF::Node.new
				@graph << [target, @v[:adr], adrs]
				@graph << [adrs, RDF[:type], @v[a.location.first]]
				@graph << [adrs, RDF[:locality], a.locality]
				@graph << [adrs, RDF[:country], (a.country.empty? ? "Australia" : a.country)]
			end
		end		
	end
	
	#------------------------
	def add_organisation(target, vcard)
		unless vcard.org.nil?
			membership = @ajo["m" << rand(1000000).to_s.ljust(6, "0")]
			@graph << [membership, RDF[:type], @org[:Membership]]
			
			# Add the target
			@graph << [membership, @org[:member], target]
			
			# Add the role title
			unless vcard.title.nil?
				role = RDF::Node.new
				@graph << [membership, @org[:role], role]
				@graph << [role, RDF::RDFS[:label], vcard.title]
			end
				
			# Add the organisation
			company_id = vcard.org.first.downcase.tr('.& ', ' -')
			company = @ajo[company_id]
			@graph << [membership, @org[:organization], company]
			@graph << [company, RDF[:type], @org[:formalOrganization]]
			@graph << [company, RDF::SKOS[:altLabel], vcard.org.first]
			@graph << [company, RDF::RDFS[:label], vcard.org.first]	
		end		
	end
	
	#------------------------
	def add_social_profiles(target, vcard)
		vcard.values("X-SOCIALPROFILE") do |p|
			acct = RDF::Node.new
			@graph << [target, RDF::FOAF[:account], acct]
			@graph << [acct, RDF[:type], RDF::FOAF[:OnlineAccount]]
			@graph << [acct, RDF::FOAF[:accountName], p.to_s]
		end
	end
	
	#------------------------
	def create_organisation(vcard)
	end
	
	#------------------------
	def to_turtle
		@graph.dump(:turtle)
	end
	
	#------------------------
	def write_as_turtle(filename)
		RDF::Turtle::Writer.open(filename) do |writer|
			writer << @graph
		end
	end
	
end

# The End
