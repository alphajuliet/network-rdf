#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'linkedin/rdf_linked_in'

describe RDFLinkedIn do
	
	before do
		@li = MyLinkedIn.new
		@net = RDFLinkedIn.new(@li)
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
		
end

# The End
