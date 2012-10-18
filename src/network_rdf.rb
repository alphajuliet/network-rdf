#!/usr/bin/env ruby

require 'rubygems'
require 'rdf'
require 'rdf/turtle'
require 'rdf/json'

class NetworkRDF
	
	attr_reader :graph
	
	def initialize(linkedin)
		@source = linkedin
		@graph = RDF::Graph.new
	end
	
	def add_subject
		ajp = RDF::Vocabulary.new("http://alphajuliet.com/ns/person#")
		p = @source.basic_profile
		name = p[:first_name] + " " + p[:last_name]
		@graph << [ajp.AndrewJ, RDF.type, RDF::FOAF.Person]
		@graph << [ajp.AndrewJ, RDF::FOAF.name, name]
	end
	
	def add_connections
		@source.connections.each do |c|
			self.add_connection(c) unless c.nil?
		end
	end
	
	def add_connection(c)
		
		ajp = RDF::Vocabulary.new("http://alphajuliet.com/ns/person#")
		
		begin
			ref = RDF::URI.new(c[:api_standard_profile_request][:url])
			name = c[:first_name] + " " + c[:last_name]
			location = c[:location][:name]
			id = c[:id]
			
			@graph << [ref, RDF.type, RDF::FOAF.Person]
			@graph << [ref, RDF::FOAF.name, name]
			@graph << [ref, RDF::FOAF.based_near, location]
			@graph << [ref, RDF::FOAF.knows, ajp.AndrewJ]
			@graph << [ref, RDF::FOAF.depiction, c[:picture_url]]

			profile = @source.connection_by_id(id, ["positions"])
			company_id = profile[:positions][:all][0][:company][:id] unless profile.nil?
						
		rescue NoMethodError => e
			# We just ignore any exceptions from missing data in the chain of accesses
			# $stderr.puts "\nError: Missing info for connection <#{name}>\n  #{e}"
			# $stderr.puts e.backtrace
		end
		
	end
	
	def to_turtle
		@graph.dump(:turtle)
	end
	
	def to_json(fname)
		RDF::JSON::Writer.open(fname) do |writer|
			graph.each_statement do |statement|
				writer << statement
			end
		end
	end
	
end

# The End
