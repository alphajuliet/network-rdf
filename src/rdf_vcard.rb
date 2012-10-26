#!/usr/bin/env ruby

require 'rdf'
require 'my_prefixes'
require 'pp'

class RDFVCard 

	def initialize(vcard=nil)
		raise ArgumentError.new("VCard cannot be empty") if vcard.nil?
		@vcard = vcard
		@triples = []
	end

	def gen_id
		@vcard.values("X-ABUID").first.split(':').first
	end
	
	def to_rdf
		@subject = RDF::AJP[gen_id]
		add_person_to(@subject)
		@triples
	end

	#------------------------
	def add_person_to(target)
		@triples << [target, RDF.type, RDF::FOAF.Person]
		@triples << [target, RDF::FOAF.name, @vcard.name.fullname]
		@triples << [target, RDF::SKOS.prefName, @vcard.name.fullname]
		
		add_card_to(target)
		add_organisation_to(target)
		add_social_profiles_to(target)
		add_relationships_to(target)
	end
	
	#------------------------
	def add_card_to(target)
		card = RDF::Node.new
		@triples << [target, RDF::GLDP.card, card]
		@triples << [card, RDF.type, RDF::V.VCard]
		@triples << [card, RDF::V.fn, @vcard.name.fullname]		

		add_emails_to(card)
		add_telephones_to(card)
		add_addresses_to(card)	
	end	
	
	#------------------------
	def add_emails_to(target)
		@vcard.emails.each do |e|
			email = RDF::Node.new
			@triples << [target, RDF::V.email, email]
			@triples << [email, RDF.type, RDF::V[e.location.first]]
			@triples << [email, RDF.value, e.to_s]
		end		
	end
	
	#------------------------
	def add_telephones_to(target)
		@vcard.telephones.each do |t|
			tel = RDF::Node.new
			@triples << [target, RDF::V.tel, tel]
			@triples << [tel, RDF.type, RDF::V[t.location.first]]
			@triples << [tel, RDF.value, t.to_s]
		end		
	end
	
	#------------------------
	def add_addresses_to(target)
		@vcard.addresses.each do |a|
			unless a.locality.nil?
				adrs = RDF::Node.new
				@triples << [target, RDF::V.adr, adrs]
				@triples << [adrs, RDF.type, RDF::V[a.location.first]]
				@triples << [adrs, RDF::V.locality, a.locality]
				@triples << [adrs, RDF::V.country, (a.country.empty? ? "Australia" : a.country)]
			end
		end		
	end
	
	#------------------------
	def add_organisation_to(target)
		unless @vcard.org.nil?
			membership = RDF::AJO["m" << rand(1000000).to_s.ljust(6, "0")]
			@triples << [membership, RDF.type, RDF::ORG.Membership]
			
			# Add the target
			@triples << [membership, RDF::ORG.member, target]
			
			# Add the role title
			unless @vcard.title.nil?
				role = RDF::Node.new
				@triples << [membership, RDF::ORG.role, role]
				@triples << [role, RDF::RDFS.label, @vcard.title]
			end
				
			# Add the organisation
			company_id = @vcard.org.first.downcase.tr('.& ', ' -')
			company = RDF::AJO[company_id]
			@triples << [membership, RDF::ORG.organization, company]
			@triples << [company, RDF.type, RDF::ORG.formalOrganization]
			@triples << [company, RDF::SKOS.altLabel, @vcard.org.first]
			@triples << [company, RDF::RDFS.label, @vcard.org.first]	
		end		
	end
	
	#------------------------
	def add_social_profiles_to(target)
		@vcard.values("X-SOCIALPROFILE") do |p|
			acct = RDF::Node.new
			@triples << [target, RDF::FOAF.account, acct]
			@triples << [acct, RDF.type, RDF::FOAF.OnlineAccount]
			@triples << [acct, RDF::FOAF.accountName, p.to_s]
		end
	end
	
	#------------------------
	def add_relationships_to(target)
		@vcard.value("item2") do |p|
			puts p.to_s
		end
	end
	
end


# The End
