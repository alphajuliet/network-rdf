#!/usr/bin/env rake

require 'fileutils'
require 'rspec/core/rake_task'
require 'rake/clean'

t = Time.new
today = t.strftime("%Y-%m-%d")

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

desc "Make sure the gems are up to date."
task :check do
	sh 'bundle install'
end

desc "Export all my contacts."
task :export do
	sh "osascript src/export-all-contacts.scpt"
	source_dir = File.join(ENV["HOME"], "Downloads")
	FileUtils.mv("#{source_dir}/contacts.vcf", "./data/contacts-#{today}.vcf")
end

desc "Generate RDF/Turtle from the contacts VCard file."
task :turtle do
	require 'src/rdf_address_book'	
	data_dir = File.expand_path(File.join(File.dirname(__FILE__), "data"))
	ab = RDFAddressBook.new_from_file(File.join(data_dir, "contacts-#{today}.vcf"))
	puts ab.write_as_turtle(File.join(data_dir, "contacts-#{today}.ttl"))
end

desc "Load RDF/Turtle into 4store. Requires the 4store web server to have been started."
task :loadrdf do
	require 'rubygems'
	require 'rest_client'
	
	# filename = ARGV[0]
	filename = "data/contacts-#{today}.ttl"
	graph    = 'http://alphajuliet.com/ns/network-rdf'
	endpoint = 'http://localhost:8000/data/'
	
	puts "Loading #{filename} into #{graph} in 4store"
	response = RestClient.put endpoint + graph, File.read(filename), :content_type => 'text/turtle'
	puts "Response #{response.code}: #{response.to_str}"	
end

desc "Run the whole sequence"
task :all => [:export, :turtle, :loadrdf]

# The End
