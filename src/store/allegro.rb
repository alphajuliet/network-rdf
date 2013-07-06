#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..")
$:.unshift File.dirname(__FILE__)

require 'config'
require 'rest_client'
require 'rdf_store'

class AllegroGraph < RdfStore

  def initialize
    config = Configuration.for('allegro')
    raise "Error: Allegro credentials not set in environment" if config.user.nil?
    @repo = config.repo
  end

  def clear_all
    dest = @repo + "/statements"
    response = RestClient.delete dest
  end

  def size
    response = RestClient.get @repo + "/size"
  end

  def load(statements)
    dest = @repo + "/statements?commit=100"
    response = RestClient.put dest, statements, :Content_Type => 'text/turtle'
  end

  def add(statements)
    dest = @repo + "/statements?commit=100"
    response = RestClient.post dest, statements, :Content_Type => 'text/turtle'
  end
end

# The End
