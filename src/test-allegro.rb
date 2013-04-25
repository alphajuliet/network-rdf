#!/usr/bin/env ruby

require 'allegro_graph'

config = {
    :host => "ec2-54-234-212-204.compute-1.amazonaws.com",
    :port => "10035",
    :username => "test",
    :password => "xyzzy",
}

server = AllegroGraph::Server.new(config)
repo = AllegroGraph::Repository.new server, "test"
repo.create_if_missing!

# The End
