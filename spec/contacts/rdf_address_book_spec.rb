#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "..", "src")
data_dir = File.expand_path(
						File.join(
							File.dirname(__FILE__), 
							"..", "..", "data"))

require 'contacts/rdf_address_book'
require 'rdf'

describe RDFAddressBook do

	before do
		@ab_empty = RDFAddressBook.new
		@ab_test1 = RDFAddressBook.new_from_file(File.join(data_dir, "contacts-test1.vcf"))
		@ab_test1.convert_to_rdf
	end
		
	it "gets instantiated" do
		@ab_empty.should_not be_nil
		@ab_empty.graph.should be_a_kind_of(RDF::Graph)
	end
	
	it "loads entries" do
		@ab_test1.graph.count.should be >(0)
	end
	
	it "contains the FOAF name" do
		query = RDF::Query.new do
			pattern [:person, RDF::FOAF.name, :name]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(3)
	end
		
	it "contains a VCard with the fullname" do
		query = RDF::Query.new do
			pattern [:card, RDF.type, RDF::V.VCard]
			pattern [:card, RDF::V.fn, :name]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(1)
		solutions.first.bound?(:name).should be_true
		solutions.first[:name].should eq("Jane Smith")
	end
	
	it "contains two phone numbers" do
		query = RDF::Query.new do
			pattern [:card, RDF.type, RDF::V.VCard]
			pattern [:card, RDF::V[:tel], :tel]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(2)
	end
	
	it "contains two email addresses" do
		query = RDF::Query.new do
			pattern [:card, RDF.type, RDF::V.VCard]
			pattern [:card, RDF::V.email, :e]
			pattern [:e, RDF.value, :address]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(2)		
		solutions.first[:address].should eq("jane.smith@example.org")
	end
	
	it "contains two social profiles" do
		query = RDF::Query.new do
			pattern [:p, RDF.type, RDF::FOAF.Person]
			pattern [:p, RDF::FOAF.account, :acct]
			pattern [:acct, RDF.type, RDF::FOAF[:OnlineAccount]]
			pattern [:acct, RDF::FOAF.accountName, :acctName]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(2)		
		solutions.first[:acctName].should eq("http://twitter.com/janesmith12345")
	end
	
	it "contains the note information" do
		query = RDF::Query.new do
			pattern [:c, RDF.type, RDF::V.VCard]
			pattern [:c, RDF::V.fn, "Jane Smith"]
			pattern [:c, RDF::V.note, :note]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(1)		
	end
	
	it "contains triples from an RDF/Turtle note" do
		query = RDF::Query.new do
			pattern [:p, RDF.type, RDF::FOAF.Person]
			pattern [:p, RDF::NET.workedAt, :c]
			pattern [:c, RDF::SKOS.prefName, "Oracle Australia"]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(1)		
	end

	it "contains a relationship" do
		query = RDF::Query.new do
			pattern [:p, RDF.type, RDF::FOAF.Person]
			pattern [:p, RDF::FOAF.knows, :name]
			pattern [:name, RDF.type, RDF::FOAF.Person]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(2)
		# solutions.first[:name].should eq("John Smith")
	end
	
	it "maps a person to an organisation" do
		query = RDF::Query.new do
			pattern [:m, RDF.type, RDF::ORG.Membership]
			pattern [:m, RDF::ORG.member, :p]
			pattern [:p, RDF.type, RDF::FOAF.Person]
			pattern [:m, RDF::ORG.organization, :org]
			pattern [:org, RDF.type, RDF::ORG.Organization]
			pattern [:org, RDF::SKOS.prefLabel, "Example Corporation"]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(1)		
	end
	
	it "contains a role" do
		query = RDF::Query.new do
			pattern [:m, RDF.type, RDF::ORG.Membership]
			pattern [:m, RDF::ORG.role, :r]
			pattern [:r, RDF.type, RDF::ORG.Role]
			pattern [:r, RDF::SKOS.prefLabel, :title]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.first[:title].should eq("CTO")
	end
	
	it "prints out the RDF" do
		puts @ab_test1.to_turtle
	end
	
end
	
# The End
