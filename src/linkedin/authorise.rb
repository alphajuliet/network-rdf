#!/usr/bin/env ruby
# Test the linkedin API and get an access token

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'rubygems'
require 'linkedin'
require 'config'

class LinkedInAuthoriser

	attr_reader :access_token, :client
	
	def initialize
		@consumer = { :token => MyConfig.get('linkedin-token'), :secret => MyConfig.get('linkedin-secret')}
		@config = { :request_token_path => '/uas/oauth/requestToken?scope=r_basicprofile+r_network' }
		@client = LinkedIn::Client.new(@consumer[:token], @consumer[:secret], @config)
		
		@access_token = [ MyConfig.get('access-token'), MyConfig.get('access-secret') ]
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