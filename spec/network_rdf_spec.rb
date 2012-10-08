#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'network_rdf'

describe NetworkRDF do
	
	before do
		@net = NetworkRDF.new(MyLinkedIn.new)
	end
	
	it "is initialised from a LinkedIn profile" do
		@net.should be_true
	end
	
	it "stores the subject as RDF statements in a graph" do
		@net.add_subject
		g = @net.graph
		g.data.size.should eq(2)
	end
	
end

# The End
