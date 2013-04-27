#!/usr/bin/env ruby

require 'configuration'

user = ENV["ALLEGRO_USER"]
pass = ENV["ALLEGRO_PASS"]

token = ENV["DYDRA_TOKEN"]

Configuration.for('rdf_store') {
    store "allegro"
    class_name 'AllegroGraph'
}

Configuration.for('allegro') {
    user "#{user}"
    repo "http://#{user}:#{pass}@ec2-54-234-212-204.compute-1.amazonaws.com:10035/repositories/network-rdf" 
    sparql "http://#{user}:#{pass}@ec2-54-234-212-204.compute-1.amazonaws.com:10035/repositories/network-rdf" 
}

Configuration.for('dydra') {
    repo "http://#{token}@api.dydra.com/alphajuliet/network-rdf/statements"
    sparql "http://#{token}@api.dydra.com/alphajuliet/network-rdf/sparql"
}

# The End
