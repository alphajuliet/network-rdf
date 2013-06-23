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
    begin
      add_triple [@subject, RDF::V.hasEmail, email]
      add_triple [email, RDF.type, RDF::V.Email]
      add_triple [email, RDF.type, RDF::V[e.value.location.first.capitalize]]
      add_triple [email, RDF::V.email, e.value.to_s]
    rescue Exception
      puts e.inspect
    end
	end
	
	def do_tel(e)
		t = e.value
		tel = RDF::Node.new
    begin
      add_triple [@subject, RDF::V.hasTelephone, tel]
      add_triple [tel, RDF.type, RDF::V[t.location.first.capitalize]] unless t.location.nil?
      add_triple [tel, RDF.type, RDF::V.Voice]
      add_triple [tel, RDF::V.telephone, t.to_s]		
    rescue Exception
      puts t.location
    end
	end

	def do_adr(e)
		a = e.value
		begin
			adrs = RDF::Node.new
			add_triple [@subject, RDF::V.hasAddress, adrs]
			add_triple [adrs, RDF.type, RDF::V[a.location.first.capitalize]]
			add_triple [adrs, RDF::V.locality, a.locality] unless a.locality.empty?
			add_triple [adrs, RDF::V.country, (a.country.empty? ? "Australia" : a.country)]
    rescue Exception
      puts a.inspect
		end
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
	
  def map_relationship(property)
    p = property
    return p if property.instance_of?(RDF::URI)
    case 
      when property =~ /(website$)|(HomePage)|(profile)/i then p = RDF::FOAF.homepage 
      when property =~ /company website$/i then p = RDF::FOAF.workplaceHomepage 
      when property =~ /blog/i then p = RDF::FOAF.weblog
      else p = RDF::RDFS.seeAlso
    end
    p
  end

	def lookup_range(property)
		range = {:class => RDF::FOAF.Person, :identifier => RDF::FOAF.name } if property == RDF::FOAF.knows
		range = {:class => RDF::ORG.Organization, :identifier => RDF::SKOS.prefLabel } if property == RDF::NET.workedAt
		range = {:class => RDF::ORG.Organization, :identifier => RDF::SKOS.prefLabel } if property == RDF::NET.worksAt
		range = {:class => RDF::FOAF.Person, :identifier => RDF::FOAF.name } if property == RDF::NET.colleagueOf
		raise ArgumentError, "Error: unrecognised property: #{property}" if range.nil?
		range
	end
	
	def process_groups
		@group.each_pair do |group, entry|
			property = RDF::Vocabulary.expand_curie(entry[:property])
			object = RDF::Vocabulary.expand_curie(entry[:object])
			return if object.nil?
				
			if object.instance_of?(RDF::URI)
        if property.instance_of?(RDF::URI)
          add_triple [@subject, property, object]
        else
          add_triple [@subject, RDF::RDFS.seeAlso, object]
        end
			else
        if property == RDF::NET.workedAt || property == RDF::NET.worksAt
          add_triple [@subject, property, RDF::AJC["org-" + RDF.Map_URI(object)]]
        elsif property == RDF::NET.colleagueOf
          target = RDF::Node.new
          add_triple [@subject, property, target]
          add_triple [target, RDF.type, RDF::FOAF.Person]
          add_triple [target, RDF::FOAF.name, object]
        else
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
