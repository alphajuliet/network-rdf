#!/usr/bin/env rake

require 'fileutils'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'rake/clean'
CLEAN.include("doc/")

desc "Generate RDF/Turtle from the contacts VCard file."
task :turtle do
	require 'src/rdf_address_book'	
	data_dir = File.expand_path(File.join(File.dirname(__FILE__), "data"))
	ab = RDFAddressBook.new
	ab.read_vcards(File.join(data_dir, "contacts-2012-10-19.vcf"))
	puts ab.to_turtle
end

desc "Make sure the gems are up to date."
task :init do
	bundler install
end

desc "Export all my contacts into the Downloads folder"
task :export do
	sh "osascript src/export-all-contacts.scpt"
	t = Time.new
	today = t.strftime("%Y-%m-%d")
	source_dir = File.join(ENV["HOME"], "Downloads")
	FileUtils.mv("#{source_dir}/contacts.vcf", "./data/contacts-#{today}.vcf")
end

# The End
