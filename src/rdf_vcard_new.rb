#!/usr/bin/env ruby

require 'rdf'
require 'my_prefixes'
require 'vcard_eventer'

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
		@subject = RDF::AJP.id
		@card = RDF::Node.new
		@triples << [@subject, RDF.type, RDF::FOAF.Person]
		@triples << [@subject, RDF::GLDP.card, @card]
		@triples << [@card, RDF.type, RDF::V.VCard]
	end
	
	#------------------------
	def do_n(name)
		@triples << [@subject, RDF::FOAF.name, name.fullname]
		@triples << [@subject, RDF::SKOS.prefName, name.fullname]
		@triples << [@card, RDF::V.fn, name.fullname]		
	end
		
	def do_email(e)
		email = RDF::Node.new
		@triples << [@card, RDF::V.email, email]
		@triples << [email, RDF.type, RDF::V[e.location.first]]
		@triples << [email, RDF.value, e.to_s]
	end
	
	def do_tel(t)
		tel = RDF::Node.new
		@triples << [@card, RDF::V.tel, tel]
		@triples << [tel, RDF.type, RDF::V[t.location.first]]
		@triples << [tel, RDF.value, t.to_s]		
	end

	def do_adr(a)
		unless a.locality.nil?
			adrs = RDF::Node.new
			@triples << [@card, RDF::V.adr, adrs]
			@triples << [adrs, RDF.type, RDF::V[a.location.first]]
			@triples << [adrs, RDF::V.locality, a.locality]
			@triples << [adrs, RDF::V.country, (a.country.empty? ? "Australia" : a.country)]
		end		
	end

	def do_title(t)
		unless title.nil?
			role = RDF::Node.new
			@triples << [@membership, RDF::ORG.role, role]
			@triples << [role, RDF::RDFS.label, title]
		end
	end
				
	def do_org(org)
		unless org.nil?
			@membership = RDF::AJO["m" << rand(1000000).to_s.ljust(6, "0")]
			@triples << [@membership, RDF.type, RDF::ORG.Membership]
			
			# Add the target
			@triples << [@membership, RDF::ORG.member, @subject]
			
			# Add the organisation
			company_id = org.first.downcase.tr('.& ', ' -')
			company = RDF::AJO[company_id]
			@triples << [@membership, RDF::ORG.organization, company]
			@triples << [company, RDF.type, RDF::ORG.formalOrganization]
			@triples << [company, RDF::SKOS.prefLabel, org.first]
		end		
	end

	def do_x_socialprofile(p)
		acct = RDF::Node.new
		@triples << [@subject, RDF::FOAF.account, acct]
		@triples << [acct, RDF.type, RDF::FOAF.OnlineAccount]
		@triples << [acct, RDF::FOAF.accountName, p.to_s]		
	end
			
	def do_x_abuid(value)
		id = value.first.split(':').first
		@triples.map! { |tr| (tr.first == RDF::AJP.id) ? [RDF::AJP[id], tr[1], tr[2]] : tr }
	end

end

# The End
