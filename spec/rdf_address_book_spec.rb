#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'rdf_address_book'

data_dir = File.expand_path(File.join(File.dirname(__FILE__), "..", "data"))

describe RDFAddressBook do

	before do
		@ab = RDFAddressBook.new
	end
	
	it "gets instantiated" do
		@ab.should_not be_nil
		@ab.graph.should be_a_kind_of(RDF::Graph)
	end
	
	it "loads entries" do
		@ab.read_vcards(File.join(data_dir, "contacts-2012-10-19.vcf"))
		@ab.graph.size.should eq(298)
		x = @ab.graph.first
		x.subject.to_s.should eq("http://alphajuliet.com/ns/people#david-clarke")
	end
	
end
	
# The End
