#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'my_profile'

describe MyProfile do
	
	it "gets initialised from LinkedIn" do
		MyProfile.new_from_LinkedIn.should eq "Andrew Joyner"
	end
	
end

# The End
