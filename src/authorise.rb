#!/usr/bin/env ruby
# Test the linkedin API and get an access token

require 'rubygems'
require 'linkedin'

consumer = { :token => '3l5b9vdnixqs', :secret => 'onY0JQlwkEcZwf6V' }
config = { :request_token_path => '/uas/oauth/requestToken?scope=r_basicprofile+r_network' }
client = LinkedIn::Client.new(consumer[:token], consumer[:secret], config)

def get_access_token(request_token)

	rtoken = request_token.token
	rsecret = request_token.secret
	
	# to test from your desktop, open the following url in your browser
	# and record the verifier code it gives you
	url = client.request_token.authorize_url
	puts "Go to #{url}"
	puts "Enter verifier: " 
	verifier = gets.strip
	
	client.authorize_from_request(rtoken, rsecret, verifier)
end

# puts get_access_token(client)
# Received 26-Sep
access_token = { :token => "393d6b72-a353-4402-bf8e-61f141d8f6e6", 
								 :secret => "365b2c3d-c9b6-4fd7-9c02-9a49ecfec0c1" }
	
client.authorize_from_access(access_token[:token], access_token[:secret])
puts "# My profile"
client.profile.to_hash.each { |k,v| puts "#{k}: #{v}" }

#puts "# My connections"
#connections = client.connections.to_hash["all"]
#puts connections.length
#connections.each do |c|
#	puts c.to_hash.values_at("first_name", "last_name").join(" ")
#end

# The End