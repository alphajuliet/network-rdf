#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'rdf'
require 'rdf/turtle'
require 'my_prefixes'
require 'contacts/vcard_eventer'

class RDFVCard < VCardEventer

	def initialize(vcard)
		raise ArgumentError.new("VCard cannot be empty") if vcard.nil?
		super(vcard)
		@triples = []
	end

	def to_rdf
		add_person
		process
		@triples
	end

	#------------------------
	def add_person
		@subject = RDF::AJC.id
		@card = RDF::Node.new
		@triples << [@subject, RDF.type, RDF::FOAF.Person]
		@triples << [@subject, RDF::GLDP.card, @card]
		@triples << [@card, RDF.type, RDF::V.VCard]
	end
	
	#------------------------
	def do_n(e)
		@triples << [@subject, RDF::FOAF.name, e.value.fullname]
		@triples << [@subject, RDF::SKOS.prefLabel, e.value.fullname]
		@triples << [@card, RDF::V.fn, e.value.fullname]		
	end
		
	def do_email(e)
		email = RDF::Node.new
		@triples << [@card, RDF::V.email, email]
		@triples << [email, RDF.type, RDF::V[e.value.location.first]]
		@triples << [email, RDF.value, e.value.to_s]
	end
	
	def do_tel(e)
		t = e.value
		tel = RDF::Node.new
		@triples << [@card, RDF::V.tel, tel]
		@triples << [tel, RDF.type, RDF::V[t.location.first]]
		@triples << [tel, RDF.value, t.to_s]		
	end

	def do_adr(e)
		a = e.value
		unless a.locality.nil?
			adrs = RDF::Node.new
			@triples << [@card, RDF::V.adr, adrs]
			@triples << [adrs, RDF.type, RDF::V[a.location.first]]
			@triples << [adrs, RDF::V.locality, a.locality]
			@triples << [adrs, RDF::V.country, (a.country.empty? ? "Australia" : a.country)]
		end
	end

	def do_title(e)
		t = e.value
		unless title.nil?
			role = RDF::Node.new
			@triples << [@membership, RDF::ORG.role, role]
			@triples << [role, RDF::RDFS.label, title]
		end
	end
				
	def do_org(e)
		org = e.value
		unless org.nil?
			@membership = RDF::AJC["m" << rand(1000000).to_s.ljust(6, "0")]
			@triples << [@membership, RDF.type, RDF::ORG.Membership]
			
			# Add the target
			@triples << [@membership, RDF::ORG.member, @subject]
			
			# Add the organisation
			company_id = "org-" + org.first.downcase.tr('\.&+ ', ' -')
			company = RDF::AJC[company_id]
			@triples << [@membership, RDF::ORG.organization, company]
			@triples << [company, RDF.type, RDF::ORG.Organization]
			@triples << [company, RDF::SKOS.prefLabel, org.first]
		end		
	end

	def do_x_socialprofile(e)
		p = e.value
		acct = RDF::Node.new
		@triples << [@subject, RDF::FOAF.account, acct]
		@triples << [acct, RDF.type, RDF::FOAF.OnlineAccount]
		@triples << [acct, RDF::FOAF.accountName, p.to_s]		
	end
			
	def do_x_abuid(e)
		id = "person-" + e.value.first.split(':').first
		@triples.map! do |tr|
			tr.map! { |x| (x == RDF::AJC.id) ? RDF::AJC[id] : x } unless tr.nil?
		end
	end
	
	def do_note(e)
		@triples << [@card, RDF::V.note, e.value.to_s]
		if (e.value =~ /rdf:\s*\{(.+)\}/m)
			rdf = $1
			# Expand prefixes into their URIs
			rdf.gsub!(/(\w+):(\S*)/) { |p| '<' + RDF::Vocabulary.expand($1) + $2 + '>'}
			# Map <> into the subject
			rdf.gsub!('<>', "<#{@subject}>")
			# Parse the RDF as Turtle statements
			# Add as triples			
			parse_turtle(rdf)
		end
	end

	def do_x_abrelatednames(e)
		@triples << [@subject, RDF::FOAF.knows, e.value]
	end
	
	def do_x_ablabel(e)
		#puts "X-ABLabel: #{e.group}, #{e.value}"
	end
	
	# Parse the given RDF and add to the triples
	def parse_turtle(text)
		r = RDF::Turtle::Reader.new(text)
		r.each_statement do |s|
			@triples << s.to_triple			
		end
	end
	
end

# The End
