#!/usr/bin/env ruby

require 'rubygems'
require 'rest_client'

filename = ARGV[0]
graph    = 'http://alphajuliet.com/ns/network-rdf'
endpoint = 'http://localhost:8000/data/'

puts "Loading #{filename} into #{graph} in 4store"
response = RestClient.put endpoint + graph, File.read(filename), :content_type => 'text/turtle'
puts "Response #{response.code}: #{response.to_str}"

# The End
