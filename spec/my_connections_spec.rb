#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'my_connections'

describe MyConnections do
	
	before do
		@connections = MyConnections.new_from_LinkedIn
	end		
	
	it "get initialised from LinkedIn" do
		@connections.size.should > 0
	end
	
end

# The End
