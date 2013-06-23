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
    
  def add_triple(tr)
    raise "Error: Malformed triple: #{tr}" if tr.length != 3
    raise "Error: Malformed triple: #{tr}" if tr[0].nil?
    raise "Error: Malformed triple: #{tr}" if tr[1].nil?
    raise "Error: Malformed triple: #{tr}" if tr[2].nil?
    @triples << tr
  end

	#------------------------
	def add_person
		@subject = RDF::AJC.id # This is a placeholder URI
		add_triple [@subject, RDF.type, RDF::FOAF.Person]
    add_triple [@subject, RDF.type, RDF::V.Individual]
		
		@group = Hash.new
	end
	
	#------------------------
	def do_n(e)
		name = e.value.fullname
    # puts name ### for DEBUG
		add_triple [@subject, RDF::FOAF.name, name]
		add_triple [@subject, RDF::V.fn, name]
	end
		
	def do_email(e)
		email = RDF::Node.new
    add_triple [@subject, RDF::V.hasEmail, email]
    add_triple [email, RDF.type, RDF::V.Email]
    add_triple [email, RDF.type, RDF::V[e.value.location.first.capitalize]] unless e.value.location.length == 0
    add_triple [email, RDF::V.email, e.value.to_s]
	end
	
	def do_tel(e)
		t = e.value
		tel = RDF::Node.new
    add_triple [@subject, RDF::V.hasTelephone, tel]
    add_triple [tel, RDF.type, RDF::V[t.location.first.capitalize]] unless t.location.length == 0
    add_triple [tel, RDF.type, RDF::V.Voice]
    add_triple [tel, RDF::V.telephone, t.to_s]		
	end

	def do_adr(e)
		a = e.value
    adrs = RDF::Node.new
    add_triple [@subject, RDF::V.hasAddress, adrs]
    add_triple [adrs, RDF.type, RDF::V[a.location.first.capitalize]] unless a.location.length == 0
    add_triple [adrs, RDF::V.locality, a.locality] unless a.locality.empty?
    add_triple [adrs, RDF::V.country, (a.country.empty? ? "Australia" : a.country)]
	end

  def do_title(e)
    title = e.value
    unless @membership.nil?
      role = RDF::Node.new
      add_triple [@membership, RDF::ORG.role, role]
      add_triple [role, RDF.type, RDF::ORG.Role]
      add_triple [role, RDF::SKOS.prefLabel, title]
    end
  end

	def do_org(e)
		org = e.value
		unless org.nil?
			@membership = RDF::AJC["m" << rand(1000000).to_s.ljust(6, "0")]
			add_triple [@membership, RDF.type, RDF::ORG.Membership]
			
			# Add the target
			add_triple [@membership, RDF::ORG.member, @subject]
			
			# Add the organisation
			company_id = RDF.Map_URI(org.first)
			company = RDF::AJO[company_id]
			add_triple [@membership, RDF::ORG.organization, company]
			add_triple [company, RDF.type, RDF::ORG.Organization]
      add_triple [company, RDF.type, RDF::V.Org]
			add_triple [company, RDF::SKOS.prefLabel, org.first]
		end		
	end
	
	def do_x_socialprofile(e)
		p = e.value
		acct = RDF::Node.new
		add_triple [@subject, RDF::FOAF.account, acct]
		add_triple [acct, RDF.type, RDF::FOAF.OnlineAccount]
		add_triple [acct, RDF::FOAF.accountName, RDF::Vocabulary.expand_curie(p)]		
	end
			
	def do_x_abuid(e)
		@id = "person-" + e.value.split(':').first
	end
	
	def do_note(e)
		add_triple [@subject, RDF::V.note, e.value.to_s]
		if (e.value =~ /rdf:\s*\{(.+)\}/m) # /m = multi-line pattern
			rdf = $1
			rdf.gsub!(/<>/, "#{@subject}")
			parse_turtle(RDF.Prefixes << rdf)
		end
	end

	def do_url(e)
		if e.group.length == 0
			property = RDF::FOAF.page
			add_triple [@subject, property, RDF::Vocabulary.expand_curie(e.value.uri)]
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
	
	def process_groups
		@group.each_pair do |group, entry|
      # puts entry.inspect
			property = RDF::Vocabulary.expand_curie(entry[:property])
			object = RDF::Vocabulary.expand_curie(entry[:object])
			next if object.nil?
				
			if object.instance_of?(RDF::URI)
        if property.instance_of?(RDF::URI)
          # Case 4
          add_triple [@subject, property, object]
        else
          # Case 2
          add_triple [@subject, RDF::RDFS.seeAlso, object]
        end
			else
        if property.instance_of?(RDF::URI)
          # Case 3
          if property == RDF::NET.workedAt || property == RDF::NET.worksAt
            # Case 3b
            add_triple [@subject, property, RDF::AJC["org-" + RDF.Map_URI(object)]]
          else
            # Case 3a
            target = RDF::Node.new
            add_triple [@subject, property, target]
            add_triple [target, RDF.type, RDF::FOAF.Person]
            add_triple [target, RDF::FOAF.name, object]
          end
        else
          # Case 1
          target = RDF::Node.new
          add_triple [@subject, RDF::FOAF.knows, target]
          add_triple [target, RDF.type, RDF::FOAF.Person]
          add_triple [target, RDF::FOAF.name, object]
        end
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
			add_triple(s)			
		end
	end
	
end

# The End
