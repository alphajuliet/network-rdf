#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'rdf_address_book'
require 'rdf'

data_dir = File.expand_path(File.join(File.dirname(__FILE__), "..", "data"))

describe RDFAddressBook do

	before do
		@ab_empty = RDFAddressBook.new
		@ab_test1 = RDFAddressBook.new_from_file(File.join(data_dir, "contacts-test1.vcf"))
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
			pattern [:person, RDF::FOAF[:name], :name]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(1)
		solutions.first[:name].should eq("Adrienne Tan")
	end
		
	it "contains a VCard with the fullname" do
		query = RDF::Query.new do
			pattern [:card, RDF[:type], RDF::URI.new("http://www.w3.org/2006/vcard/ns#VCard")]
			pattern [:card, RDF::URI.new("http://www.w3.org/2006/vcard/ns#fn"), :name]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(1)
		solutions.first.bound?(:name).should be_true
		solutions.first[:name].should eq("Adrienne Tan")
	end
	
	it "contains all the phone numbers" do
		query = RDF::Query.new do
			pattern [:card, RDF[:type], RDF::URI.new("http://www.w3.org/2006/vcard/ns#VCard")]
			pattern [:card, RDF::URI.new("http://www.w3.org/2006/vcard/ns#tel"), :tel]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(2)
	end
	
	it "contains an email address" do
		query = RDF::Query.new do
			pattern [:card, RDF[:type], RDF::URI.new("http://www.w3.org/2006/vcard/ns#VCard")]
			pattern [:card, RDF::URI.new("http://www.w3.org/2006/vcard/ns#email"), :e]
			pattern [:e, RDF[:value], :address]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(1)		
		solutions.first[:address].should eq("actan@brainmates.com.au")
	end
	
	it "contains two social profiles" do
		query = RDF::Query.new do
			pattern [:p, RDF[:type], RDF::FOAF[:Person]]
			pattern [:p, RDF::FOAF[:account], :acct]
			pattern [:acct, RDF[:type], RDF::FOAF[:OnlineAccount]]
			pattern [:acct, RDF::FOAF[:accountName], :acctName]
		end
		solutions = query.execute(@ab_test1.graph)
		solutions.count.should eq(2)		
		solutions.first[:acctName].should eq("http://www.linkedin.com/in/adriennetan")
	end
	
	it "prints out the RDF" do
		puts @ab_test1.to_turtle
	end
	
end
	
# The End
