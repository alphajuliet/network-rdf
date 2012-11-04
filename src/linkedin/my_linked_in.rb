#!/usr/bin/env ruby
# LinkedIn information

require 'rubygems'
#require 'linkedin'
require 'linkedin/authorise'

# Useful function to turn string keys into symbols in a hash
def symbolize(obj)
    return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  symbolize(v); memo} if obj.is_a? Hash
    return obj.inject([]){|memo,v    | memo           << symbolize(v); memo} if obj.is_a? Array
    return obj
end

# An interface to the LinkedIn API 
class MyLinkedIn

	attr_reader :client
	
	# Create and authorise the client from the hard-coded access keys
	def initialize
		auth = LinkedInAuthoriser.new
		auth.authorise
		@client = auth.client
		
		@@cache_dir = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "cache"))
		@@max_age = 604800 # Cache for 7 days (in seconds)
	end

	#-------------------------------
	# Get the raw basic profile
	def basic_profile
		read_and_cache("basic_profile") do
			symbolize(@client.profile.to_hash)
		end
	end

	# Get all the raw first-level connections, and cache result because the call is expensive
	def connections
		read_and_cache("connections") do
			symbolize(@client.connections.to_hash)[:all]
		end
	end
	
	# Get a profile for a given ID
	def connection_by_id(id, fields=["first_name", "last_name", "api_standard_profile_request"])
		options = {:id => id, :fields => URI::encode(fields.join(','))}
		symbolize(@client.profile(options).to_hash)
	end
	
	# Get the positions
	def positions(id)
		connection_by_id(id, ["positions"])		
	end
	
	# Get company information
	def company_by_id(id, fields=["name", "website-url"])
		return nil if id.nil?
		options = {:id => id, :fields => URI::encode(fields.join(','))}
		symbolize(@client.company(options).to_hash)
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