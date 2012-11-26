#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..")
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
		finalise
		@triples
	end

	#------------------------
	def add_person
		@subject = RDF::AJC.id
		@card = RDF::Node.new
		@triples << [@subject, RDF.type, RDF::FOAF.Person]
		@triples << [@subject, RDF::GLDP.card, @card]
		@triples << [@card, RDF.type, RDF::V.VCard]

		# I know every contact
		# me = RDF::Node.new
		# @triples << [me, RDF::FOAF.name, "Andrew Joyner"]
		# @triples << [me, RDF::FOAF.knows, @subject]
		
		@group = Hash.new
	end
	
	#------------------------
	def do_n(e)
		name = e.value.fullname
		@triples << [@subject, RDF::FOAF.name, name]
		@triples << [@card, RDF::V.fn, name]
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
		title = e.value
		role = RDF::Node.new
		@triples << [@membership, RDF::ORG.role, role]
		@triples << [role, RDF.type, RDF::ORG.Role]
		@triples << [role, RDF::SKOS.prefLabel, title]
	end
				
	def do_org(e)
		org = e.value
		unless org.nil?
			@membership = RDF::AJC["m" << rand(1000000).to_s.ljust(6, "0")]
			@triples << [@membership, RDF.type, RDF::ORG.Membership]
			
			# Add the target
			@triples << [@membership, RDF::ORG.member, @subject]
			
			# Add the organisation
			company_id = "org-" + org.first.downcase.tr('\.&+ ', '-')
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
		@triples << [acct, RDF::FOAF.accountName, RDF::Vocabulary.expand_curie(p)]		
	end
			
	def do_x_abuid(e)
		@id = "person-" + e.value.split(':').first
	end
	
	def do_note(e)
		@triples << [@card, RDF::V.note, e.value.to_s]
		if (e.value =~ /rdf:\s*\{(.+)\}/m) # /m = multi-line pattern
			rdf = $1
			rdf.gsub!(/<>/, "#{@subject}")
			parse_turtle(RDF.Prefixes << rdf)
		end
	end

	def do_url(e)
		if e.group.length == 0
			property = RDF::FOAF.page
			@triples << [@subject, property, RDF::Vocabulary.expand_curie(e.value.uri)]
		else
			@group[e.group] = Hash.new if @group[e.group].nil?
			@group[e.group][:object] = e.value.uri
		end
	end
	
	def do_x_abrelatednames(e)
		@group[e.group] = Hash.new if @group[e.group].nil?
		@group[e.group][:object] = e.value
	end
	
	def do_x_ablabel(e)
		@group[e.group] = Hash.new if @group[e.group].nil?
		@group[e.group][:property] = e.value
	end
		
	def do_impp(e)
		# Do nothing
	end
	
	#------------------------
	def patch_subject_id
		@triples.map! do |tr|
			next if tr.nil?
			next if tr.instance_of?(RDF::Statement)
			tr.map! { |x| (x == RDF::AJC.id) ? RDF::AJC[@id] : x }
		end				
	end
	
	def map_relationship(property)
		p = property
		return p if property.instance_of?(RDF::URI)
		p = RDF::RDFS.seeAlso # default
		p = RDF::FOAF.homepage if property =~ /(website$)|(HomePage)|(profile)/i
		p = RDF::FOAF.workplaceHomepage if property =~ /company website$/i
		p = RDF::FOAF.weblog if property =~ /blog/i
		p
	end
	
	def lookup_range(property)
		range = {:class => RDF::FOAF.Person, :identifier => RDF::FOAF.name } if property == RDF::FOAF.knows
		range = {:class => RDF::ORG.Organization, :identifier => RDF::SKOS.prefLabel } if property == RDF::NET.workedAt
		raise ArgumentError, "Error: unrecognised property: #{property}" if range.nil?
		range
	end
	
	def process_groups
		@group.each_pair do |group, entry|
			property = RDF::Vocabulary.expand_curie(entry[:property])
			object = RDF::Vocabulary.expand_curie(entry[:object])
			return if object.nil?
				
			# If the target is _not_ already a URI then we need a layer of indirection
			if object.instance_of?(RDF::URI)
				property = map_relationship(property)
				return if property.nil?
				@triples << [@subject, property, object]
			else
				target = RDF::Node.new
				property = RDF::FOAF.knows unless property.instance_of?(RDF::URI) 
				x = lookup_range(property)
				@triples << [target, RDF.type, x[:class]]
				@triples << [@subject, property, target]
				@triples << [target, x[:identifier], object]
			end
				
		end
	end
	
	def finalise
		process_groups
		patch_subject_id
	end
	
	# Parse the given RDF and add to the triples
	def parse_turtle(text)
		r = RDF::Turtle::Reader.new(text)
		r.each_statement do |s|
			@triples << s			
		end
	end
	
end

# The End
