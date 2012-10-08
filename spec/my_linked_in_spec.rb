#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'my_linked_in'

describe MyLinkedIn do
	
	before do
		@li = MyLinkedIn.new
	end
	
	it "gets initialised" do
		@li.client.should be_true
	end
	
	it "returns my basic profile" do
		me = @li.basic_profile
		me.first_name.should eq("Andrew")
	end
	
	it "returns my connections" do
		conn = @li.connections
		conn.size.should > 0
	end
	
end

# The End
