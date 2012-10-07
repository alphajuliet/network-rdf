#!/usr/bin/env ruby
# LinkedIn information

require 'rubygems'
require 'linkedin'

# An interface to the LinkedIn API 
class MyLinkedIn

	# Create and authorise the client from the hard-coded access keys
	def initialize
		consumer = { :token => "3l5b9vdnixqs", :secret => "onY0JQlwkEcZwf6V" }
		config = { :request_token_path => "/uas/oauth/requestToken?scope=r_basicprofile+r_network" }
		@client = LinkedIn::Client.new(consumer[:token], consumer[:secret], config)
		
		# Access token generated on 26-Sep-12. Valid for 30 days.
		access = { 
			:token => "393d6b72-a353-4402-bf8e-61f141d8f6e6", 
			:secret => "365b2c3d-c9b6-4fd7-9c02-9a49ecfec0c1" 
		}
		@client.authorize_from_access(access[:token], access[:secret])
	end

	# Get the basic profile
	def basic_profile
		@client.profile.to_hash
	end

	# Get all the first-level connections
	def connections
		@client.connections.to_hash["all"]
	end

end

# The End