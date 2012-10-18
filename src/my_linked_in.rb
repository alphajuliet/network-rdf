#!/usr/bin/env ruby
# LinkedIn information

require 'rubygems'
require 'linkedin'

# Useful function to turn string keys into symbols
def symbolize_keys(h) 
	Hash[h.map{|(k,v)| [k.to_sym,v]}]
end

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
	def basic_profile
		read_and_cache("basic_profile") do
			symbolize_keys(@client.profile.to_hash)
		end
	end

	# Get all the raw first-level connections, and cache result because the call is expensive
	def connections
		read_and_cache("connections") do
			symbolize_keys(@client.connections.to_hash)[:all]
		end
	end
	
	# Get a profile for a given ID
	def connection_by_id(id, fields=["first_name", "last_name"])
		options = {:id => id, :fields => URI::encode(fields.join(','))}
		symbolize_keys(@client.profile(options).to_hash)
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
		
end

# The End