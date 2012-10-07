#!/usr/bin/env ruby

require 'my_linked_in'

# My LinkedIn profile
class MyProfile

	attr_reader :name

	def initialize()
		@name = "no name"
	end

	# Create from LinkedIn basic profile
	def MyProfile.new_from_LinkedIn
		l = MyLinkedIn.new
		@profile = l.basic_profile
		@name = @profile.values_at("first_name", "last_name").join(" ")
	end

end

# The End