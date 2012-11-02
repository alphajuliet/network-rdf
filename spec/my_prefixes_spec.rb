#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'my_prefixes'

describe RDF do

	it "contains prefixes" do
		RDF::PREFIX.size.should be > 0
		RDF::PREFIX[:rdf].should eq("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
	end
	
	it "serialises prefixes into Turtle" do
		RDF.Prefixes(:turtle).should =~ /^@prefix rdf:/
	end
	
	it "serialises prefixes into SPARQL" do
		RDF.Prefixes(:sparql).should =~ /^PREFIX rdf:/
	end
	
end
