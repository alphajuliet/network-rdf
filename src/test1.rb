#!/usr/bin/env ruby

require 'my_linked_in'
require 'network_rdf'

l = MyLinkedIn.new
n = NetworkRDF.new(l)
c = l.connections
n.add_connection(c[0])
n.to_json("../data/connections.json")

# The End
