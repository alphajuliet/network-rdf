#!/usr/bin/env rake

$:.unshift File.join(File.dirname(__FILE__), "src")
require 'fileutils'
require 'rspec/core/rake_task'
require 'rake/clean'

t = Time.new
today = t.strftime("%Y-%m-%d")

# Directories
here = File.dirname(__FILE__)
data_dir = File.expand_path(File.join(here, "data"))
ex_dir = File.expand_path(File.join(here, "examples"))
web_dir = File.expand_path(File.join(here, "src", "web"))

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

#----------------
desc "Make sure the gems are up to date."
task :check do
	sh 'bundle install'
end

#----------------
namespace :contacts do

	desc "Export all my contacts."
	task :export do
		sh "osascript src/contacts/export-all-contacts.scpt"
		source_dir = File.join(ENV["HOME"], "Downloads")
		FileUtils.mv(File.join(source_dir, "contacts.vcf"), File.join(data_dir, "contacts-#{today}.vcf"))
	end
	
	desc "Generate RDF/Turtle from the contacts VCard file."
	task :turtle do
		require 'contacts/rdf_address_book'	
		ab = RDFAddressBook.new_from_file(File.join(data_dir, "contacts-#{today}.vcf"))
		ab.convert_to_rdf
		ab.write_as_turtle(File.join(data_dir, "contacts-#{today}.ttl"))
	end

	desc "Load RDF/Turtle into 4store. Requires the 4store web server to have been started."
	task :load do
		require 'rubygems'
		require 'rest_client'

		# Files to load
		files = ["statements-1.ttl", "contacts-#{today}.ttl"]
		graph    = 'http://alphajuliet.com/ns/network-rdf'
		endpoint = 'http://localhost:8000/data/'
		
		files.each do |fname|
			filename = File.join(data_dir, fname)
			puts "Loading #{filename} into #{graph} in 4store"
			response = RestClient.put endpoint + graph, File.read(filename), :content_type => 'text/turtle'
			puts "Response #{response.code}: #{response.to_str}"	
		end
	end

	desc "Export, transform, and load contact info into the triple store."
	task :etl => ['contacts:export', 'contacts:turtle', 'contacts:load']

	desc "Print out all the prefixes"
	task :prefixes do
		require 'my_prefixes'
		puts RDF.Prefixes(:sparql)
	end
	
end

#----------------
namespace :linkedin do
	
	desc "Get an updated access token from LinkedIn"
	task :get_token do
		require 'linkedin/authorise'
		auth = LinkedInAuthoriser.new
		auth.get_access_token
	end
	
	desc "Test the LinkedIn access token"
	task :test do
		require 'linkedin/authorise'
		auth = LinkedInAuthoriser.new
		auth.test_access_token
	end
	
	desc "Transform my LinkedIn connectsion to RDF"
	task :turtle do
		require 'linkedin/rdf_linked_in'
		n = RDFLinkedIn.new
		n.add_subject
		n.add_connections
		n.write_as_turtle(File.join(data_dir, "connections-#{today}.ttl"))
	end
	
end

#----------------
namespace :rdfstore do

	desc "Create and start the 4store triple store"
	task :start do
		rdf_store_path = "/Applications/4store.app/Contents/MacOS/bin"
		setup = File.join(rdf_store_path, "4s-backend-setup")
		start = File.join(rdf_store_path, "4s-backend")
		server = File.join(rdf_store_path, "4s-httpd")
		instance = "test"
		sh "#{setup} #{instance}"
		sh "#{start} #{instance}"
		sh "#{server} -p 8000 #{instance}"
	end

end

#----------------
namespace :web do
	
	desc "Start the web UI"
	task :start do
		cmd = "ruby -rubygems " + File.join(web_dir, "web_sparql.rb")
		sh cmd
	end
	
end

#----------------
desc "Run a SPARQL select query"
task :select, :query do |t, args|
	require 'sparql_client'
	src = File.join(ex_dir, args[:query] + ".sparql")
	puts "Run examples/#{src}"
	puts SparqlClient.select(src)
end

desc "Run a SPARQL construct query"
task :construct, :query do |t, args|
	require 'sparql_client'
	src = File.join(ex_dir, args[:query] + ".sparql")
	puts "Run examples/#{src}"
	SparqlClient.construct(src)
end


# The End
