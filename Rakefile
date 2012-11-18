#!/usr/bin/env rake

$:.unshift File.join(File.dirname(__FILE__), "src")
require 'fileutils'
require 'rspec/core/rake_task'
require 'rake/clean'
require 'config'


t = Time.new
today = t.strftime("%Y-%m-%d")

# Directories
here = File.dirname(__FILE__)
config = YAML.load(File.open(File.join(here, "src", "config.yaml")))
data_dir = File.expand_path(File.join(here, "data"))
ex_dir = File.expand_path(File.join(here, "examples"))
web_dir = File.expand_path(File.join(here, "src", "web"))

contacts_vcf = File.join(data_dir, "contacts-#{today}.vcf")
contacts_ttl = File.join(data_dir, "contacts-#{today}.ttl")

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
		FileUtils.mv(File.join(source_dir, "contacts.vcf"), contacts_vcf)
	end
	
	desc "Generate RDF/Turtle from the contacts VCard file."
	task :turtle => [:export] do
		require 'contacts/rdf_address_book'	
		puts "Writing to #{contacts_ttl}"
		ab = RDFAddressBook.new_from_file(contacts_vcf)
		ab.convert_to_rdf
		ab.write_as_turtle(contacts_ttl)
	end
	
	desc "Load RDF/Turtle into the triple store."
	task :load do
		require 'rubygems'
		require 'rest_client'                     

		# Files to load
		files = ["statements-1.ttl", "contacts-#{today}.ttl", "inferences.ttl"]
		graph    = 'http://alphajuliet.com/ns/network-rdf'
		endpoint = MyConfig.get('repo-endpoint')
		
		files.each do |fname|
			filename = File.join(data_dir, fname)
			puts "Loading #{filename} into #{graph} in 4store"
			response = RestClient.post endpoint, File.read(filename), :content_type => 'text/turtle'
			puts "Response #{response.code}: #{response.to_str}"	
		end
	end

	desc "Update the triple store"
	task :update do
		require 'rubygems'
		require 'rest_client'
		endpoint = MyConfig.get('repo-endpoint')
		puts "Updating the store with #{contacts_ttl}"
		response = RestClient.put endpoint, File.read(contacts_ttl), :content_type => 'text/turtle'
		puts "Response #{response.code}: #{response.to_str}"	
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
	
	desc "Transform my LinkedIn connections to RDF"
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

	desc "Create and start the local 4store triple store"
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

	desc "Clear the repository"
	task :clear do
		require 'sparql_client'
		# puts SparqlClient.clear("GRAPH <" + MyConfig.get('graph-uri') + ">")
		puts SparqlClient.clear("DEFAULT")
	end
	
	desc "Insert triples into the repo using SPARQL INSERT"
	task :load do
		require 'sparql_client'
		src_file = File.new(contacts_ttl)
		triples = src_file.readlines
		puts SparqlClient.insert(triples.join("\n"))
	end
	
	desc "Load the repository with the latest triples"
	task :import do
		require 'rest_client'
		puts "Uploading #{contacts_ttl}"
		response = RestClient.put MyConfig.get('repo-endpoint'), 
			{ :file => File.new(contacts_ttl), :content_type => "multipart/form-data" } 
		puts response
	end
	
end

#----------------
namespace :web do
	desc "Start the web UI"
	task :start do
		cmd = "ruby -rubygems " + File.join(web_dir, "home.rb")
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
