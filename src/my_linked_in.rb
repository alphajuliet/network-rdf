#!/usr/bin/env ruby
# LinkedIn information

require 'rubygems'
require 'linkedin'

# An interface to the LinkedIn API 
class MyLinkedIn

	attr_reader :client
	
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
		
		@@cache_dir = File.expand_path(File.join(File.dirname(__FILE__), "..", "cache"))
		@@max_age = 604800 # Cache for 7 days (in seconds)
	end

	#-------------------------------
	# Get the raw basic profile
	def get_basic_profile
		read_and_cache("basic_profile") do
			@client.profile.to_hash
		end
	end

	# Get all the raw first-level connections, and cache result because the call is expensive
	def get_connections
		read_and_cache("connections") do
			@client.connections.to_hash["all"]
		end
	end
	
	#-------------------------------
	# Read and cache the data
	def read_and_cache(label="data", &block)
		file_path = File.join(@@cache_dir, label)
		data = nil # Declare before use
		
		if (File.exists? file_path) && (Time.now - File.mtime(file_path) < @@max_age)
			File.open(file_path, "r") do |f|
				data = Marshal.load(f)
			end
		else
			File.open(file_path, "w") do |f|
				data = block.call
				Marshal.dump(data, f)
			end
		end
		return data
	end
	
	#-------------------------------
	# These two methods can be overridden to format the responses differently.
	
	# Returns the basic profile of the LinkedIn client.
	def basic_profile
		self.get_basic_profile
	end
	
	# Returns the first-level connections for the LinkedIn client
	def connections
		self.get_connections
	end
	
end

# The End