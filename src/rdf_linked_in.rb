#!/usr/bin/env ruby

require 'rubygems'
require 'rdf'
require 'rdf/turtle'
require 'rdf/json'
require 'my_linked_in'
require 'my_prefixes'
require 'pp'

class RDFLinkedIn
	
	attr_reader :graph
	
	def initialize(linkedin=MyLinkedIn.new)
		@source = linkedin
		@graph = RDF::Graph.new
	end
		
	def add_subject
		p = @source.basic_profile
		name = p[:first_name] + " " + p[:last_name]
		@graph << [RDF::AJP[:AndrewJ], RDF[:type], RDF::FOAF[:Person]]
		@graph << [RDF::AJP[:AndrewJ], RDF::FOAF[:name], name]
	end
	
	def add_connections
		@source.connections.each do |c|
			self.add_connection(c) unless c.nil?
		end
	end
	
	def add_connection(conn)	
		begin
			person = RDF::URI.new(conn[:api_standard_profile_request][:url])
			name = conn[:first_name] + " " + conn[:last_name]
			location = conn[:location][:name]
			id = conn[:id]
			
			@graph << [person, RDF.type, RDF::FOAF[:Person]]
			@graph << [person, RDF::FOAF[:name], name]
			@graph << [person, RDF::FOAF[:based_near], location]
			@graph << [RDF::AJP[:AndrewJ], RDF::FOAF[:knows], person]
			@graph << [person, RDF::FOAF[:depiction], conn[:picture_url]] unless conn[:picture_url].nil?

			pos = @source.positions(id)
			if (pos[:positions][:total] > 0)
				c_id = pos[:positions][:all][0][:company][:id]
				unless c_id.nil?
					c_data = @source.company_by_id(c_id)
					c_url = c_data[:website_url]
					@graph << [person, RDF::FOAF[:workplaceHomePage], c_url] unless c_url.nil?
				end
			end
			
		rescue NoMethodError => e
			# Inform but continue
			$stderr.puts "\nError: Missing info for connection <#{name}>\n  #{e}"
			# $stderr.puts e.backtrace
		end
		
	end
		
	def to_turtle
		@graph.dump(:turtle)
	end
	
	def write_as_turtle(fname)
		RDF::Turtle::Writer.open(fname) do |writer|
			writer << @graph
		end
	end	
	
	def write_as_json(fname)
		RDF::JSON::Writer.open(fname) do |writer|
			writer << @graph
		end
	end
	
end

# The End
