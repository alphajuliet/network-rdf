#!/usr/bin/env rake

$:.unshift File.join(File.dirname(__FILE__), "src")
require 'fileutils'
require 'rspec/core/rake_task'
require 'rake/clean'
require 'config'
require 'rest_client'
require 'sparql_client'
require 'dydra'
require 'store/allegro'

t = Time.new
today = t.strftime("%Y-%m-%d")

# Directories
here = File.dirname(__FILE__)
config = YAML.load(File.open(File.join(here, "src", "config.yaml")))
data_dir = File.expand_path(File.join(here, "data"))
ex_dir = File.expand_path(File.join(here, "examples"))
query_dir = File.expand_path(File.join(here, "src", "query"))
web_dir = File.expand_path(File.join(here, "src", "web"))

contacts_vcf = File.join(data_dir, "contacts-#{today}.vcf")
contacts_ttl = File.join(data_dir, "contacts-#{today}.ttl")
inferred_ttl = File.join(data_dir, "inferred-#{today}.ttl")

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

#----------------
db = AllegroGraph.new

desc "Generate updated contacts"
task :generate => ['contacts:export', 'contacts:turtle']

desc "Load contacts"
task :load do
    num = db.load_from_file(contacts_ttl)
    puts "#{num} triples loaded."
end

desc "Infer relationships"
task :infer => 'contacts:infer' do
    num = db.add_from_file(inferred_ttl)
    puts "#{num} inferred triples added."
end
    
desc "Export, generate, load, infer, update"
task :full_update => [:generate, :load, :infer]

#----------------
namespace :contacts do

	desc "Export all my contacts."
	task :export do
		puts "# Exporting contact data"
		sh "osascript src/contacts/export-all-contacts.scpt"
		source_dir = File.join(ENV["HOME"], "Downloads")
		FileUtils.mv(File.join(source_dir, "contacts.vcf"), contacts_vcf)
	end
	
	desc "Generate RDF/Turtle from the contacts VCard file."
	task :turtle do
		puts "# Generating RDF and writing to #{contacts_ttl}"
		require 'contacts/rdf_address_book'	
		ab = RDFAddressBook.new_from_file(contacts_vcf)
		ab.convert_to_rdf
		ab.write_as_turtle(contacts_ttl)
	end
	
	desc "Generate inferred triples from repository"
	# This should only be run after the asserted statements have been uploaded, because it needs to make queries against _those_ statements.
	task :infer do
		puts "# Generating inferred statements and writing to #{inferred_ttl}"
		File.open(inferred_ttl, "w+") do |out|
			Dir.glob(File.join(query_dir, "infer*.sparql")) do |src|
				puts "# Running query in #{src}"
				out.write(SparqlClient.construct(src))
			end
		end
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
namespace :fourstore do

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

end

#----------------
namespace :dydra do

	desc "Get number of triples"
	task :size do
		Dydra.setup!(:token => MyConfig.get["dydra"]["token"])
		account = Dydra::Account.new('alphajuliet')
		repo = account[MyConfig.get["dydra"]["repo-name"]]
		puts "#{repo.count} triples"
	end
	
	desc "Clear all statements"
	task :clear_all do
		Dydra.setup!(:token => MyConfig.get["dydra"]["token"])
		account = Dydra::Account.new('alphajuliet')
		repo = account[MyConfig.get["dydra"]["repo-name"]]
		repo.clear!
	end
	
	desc "Load new triples"
	task :load do
		puts "Loading triples from #{contacts_ttl}"
		Dydra.setup!(:token => MyConfig.get["dydra"]["token"])
		account = Dydra::Account.new('alphajuliet')
		repo = account[MyConfig.get["dydra"]["repo-name"]]
		RDF::Reader.open(contacts_ttl) do |reader|
			statements = []
			reader.each_statement do |statement|
				statements << statement
			end
		end
		repo.import!(statements)
	end
	
end

#----------------
namespace :allegro do

    desc "Get the number of triples"
    task :size do
        response = AllegroGraph.new.size
        puts "#{response} triples."
    end

    desc "Clear all triples"
    task :clear_all do
        response = AllegroGraph.new.clear_all
        puts "#{response} triples deleted."
    end
    
    desc "Load new triples"
    task :load, :src do |t, args|
        response = AllegroGraph.new.load_from_file(args[:src])
        puts "#{response} triples loaded."
    end

    desc "Add triples"
    task :add, :query do |t, args|
        response = AllegroGraph.new.add_from_file(args[:src])
        puts "#{response} triples added."
    end

end
#----------------
namespace :web do
	desc "Start the web UI"
	task :start do
		if ENV["PORT"].nil?
			puts "Environment setting PORT not set"
		else
			puts "Running on port #{ENV["PORT"]}"
			cmd = "ruby -rubygems " + File.join(web_dir, "home.rb") + " -p $PORT"
			sh cmd
		end
	end
end

#----------------
# Various other tasks

desc "Print out all my prefixes in RDF/Turtle format"
task :prefixes do
	require 'my_prefixes'
	puts RDF.Prefixes(:sparql)
end

#----------------
namespace :sparql do
	desc "Run a SPARQL select query"
	task :select, :query do |t, args|
		src = File.join(ex_dir, args[:query] + ".sparql")
		puts "# Running query in #{src}"
		puts SparqlClient.select(src)
	end
	
	desc "Run a SPARQL construct query"
	task :construct, :query do |t, args|
		src = File.join(ex_dir, args[:query] + ".sparql")
		puts "# Running query in #{src}"
		puts SparqlClient.construct(src)
	end
end
# The End
