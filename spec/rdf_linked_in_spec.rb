#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'network_rdf'

describe NetworkRDF do
	
	before do
		@li = MyLinkedIn.new
		@net = NetworkRDF.new(@li)
	end
	
	it "is initialised from a LinkedIn profile" do
		@net.should be_true
	end
	
	it "stores the subject as RDF statements in a graph" do
		@net.add_subject
		g = @net.graph
		g.count.should eq(2)
	end
	
	it "adds a connection" do
		n = @net.graph.count
		c = @li.connections
		@net.add_connection(c[0])
		@net.graph.count.should be >n
	end
	
	it "returns Turtle" do
		
	end
	
	it "returns JSON" do
		
	end
	
end

# The End
