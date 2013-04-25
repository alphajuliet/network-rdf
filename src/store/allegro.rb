#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..")
$:.unshift File.dirname(__FILE__)

require 'config'
require 'rest_client'
require 'rdf_store'

class AllegroGraph < RdfStore

    def initialize
        @config = MyConfig.get["allegro"]
    end

    def clear_all
        dest = @config["repo"] + "/statements"
        response = RestClient.delete dest
    end

    def size
        repo = @config["repo"]
        response = RestClient.get repo + "/size"
    end

    def load(statements)
        dest = @config["repo"] + "/statements?commit=100"
        response = RestClient.put dest, statements, :Content_Type => 'text/turtle'
    end

    def add(statements)
        dest = @config["repo"] + "/statements?commit=100"
        response = RestClient.post dest, statements, :Content_Type => 'text/turtle'
    end
end

# The End
