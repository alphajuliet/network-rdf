#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'linkedin/my_linked_in'

describe MyLinkedIn do

=begin	

	before do
		@li = MyLinkedIn.new
	end
	
	it "gets initialised" do
		@li.client.should be_true
	end
	
	it "returns my basic profile" do
		me = @li.basic_profile
		me[:first_name].should eq("Andrew")
	end
	
	it "returns my connections" do
		conns = @li.connections
		conns.size.should > 0
		conns[0][:first_name].should eq("Sherine")
	end
	
	it "returns a given profile" do
		id = "dSRZcT0pNb"
		person = @li.connection_by_id(id)
		person[:first_name].should eq("Sherine")
		person[:api_standard_profile_request][:url].should eq("http://api.linkedin.com/v1/people/dSRZcT0pNb")
		positions = @li.positions(id)
		positions[:positions][:total].should eq(0)
	end
	
	it "returns a given company" do
		id = "1028"
		company = @li.company_by_id(id)
		company[:name].should eq("Oracle")
		company[:website_url].should eq("http://www.oracle.com")
	end

=end

end

# The End
