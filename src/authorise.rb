#!/usr/bin/env ruby
# Test the linkedin API and get an access token

require 'rubygems'
require 'linkedin'

class LinkedInAuthoriser

	attr_reader :access_token, :client
	
	def initialize
		@consumer = { :token => '3l5b9vdnixqs', :secret => 'onY0JQlwkEcZwf6V' }
		@config = { :request_token_path => '/uas/oauth/requestToken?scope=r_basicprofile+r_network' }
		@client = LinkedIn::Client.new(@consumer[:token], @consumer[:secret], @config)
		
		# Retrieved 26-Sep
		@access_token = [ "393d6b72-a353-4402-bf8e-61f141d8f6e6", "365b2c3d-c9b6-4fd7-9c02-9a49ecfec0c1" ]
	end
	
	def authorise
		@client.authorize_from_access(@access_token[0], @access_token[1])
		@client
	end
	
	def get_access_token
		rtoken = @client.request_token.token
		rsecret = @client.request_token.secret

		url = @client.request_token.authorize_url
		puts "Go to #{url}"
		print "Enter verifier: " 
		verifier = gets.strip
		@access_token = @client.authorize_from_request(rtoken, rsecret, verifier)
		puts "Access token: "
		puts @access_token
	end
	
	def test_access_token
		authorise
		puts "# My profile"
		@client.profile.to_hash.each { |k,v| puts "#{k}: #{v}" }	
	end
		
end

# The End