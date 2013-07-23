#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..")
require 'sinatra'
require 'markaby'
require 'sparql_client'
require 'rest_client'
require 'my_prefixes'
require 'json'
require 'web/sparql_queries'
require 'web/admin_queries'
require 'config'

# Set up partial directory in template search path
here = File.dirname(__FILE__)
set :views, [File.join(here, "views"), File.join(here, "views", "partial")]
helpers do
  def find_template(views, name, engine, &block)
    Array(views).each { |v| super(v, name, engine, &block) }
  end
end

helpers SparqlQueries, AdminQueries

#------------------------------
def to_json(query_result)
	array = []
	query_result.each_solution do |solution|
		hash = Hash.new
		solution.each_binding { |name, value| hash[name] = value.to_s }
		array << hash
	end
	JSON.pretty_generate(array)
end	

# Extract the basic SPARQL results into a hash of arrays
def parse_json(json)
  return nil if json.nil?
  h = JSON.parse(json)
  data = h['results']['bindings']
  {
    :headings => h['head']['vars'], 
    :rows => data.map {|i| i.to_a.map {|x| x[1]['value']}}
  }
end

def render_on(template, result=nil)
	if request.accept? 'text/html'
		markaby template, :locals => { :result => result } 
  else
    result
	end
end

def render_json_on(template, result=nil)
	if request.accept? 'text/html'
		markaby template, :locals => { :result => parse_json(result) } 
  else
    result
	end
end

#------------------------------
get '/' 												do markaby :home end

# HTML and JSON formats
get '/people/names'							do render_json_on(:people, cmd_people_names) end
get '/people/knows'							do render_json_on(:query1, cmd_people_knows) end
get '/org/:orgname/people' 			do render_json_on(:organisation, cmd_org_people) end
get '/org/count_by_person' 			do render_json_on(:query1, cmd_org_count_by_person) end
get '/no-email' 								do render_json_on(:query1, cmd_no_email) end
get '/repo'											do render_on(:repo, cmd_repo) end

# Visualisations
get '/viz/org/count_by_person'	do markaby :viz1 end
get '/viz/people/knows'					do markaby :viz2 end
get '/viz/person/:name'         do markaby :viz3 end

# Composite views, no data
get '/person/:name', 
    :provides => "html"         do render_json_on(:person) end

# Data only, no custom view
get '/person/:name/knows'				do render_json_on(:query1, cmd_person_knows) end
get '/person/:name/card'				do render_json_on(:query1, cmd_person_card) end
get '/person/:name/org'					do render_json_on(:query1, cmd_person_org) end

# Native SPARQL query
get '/sparql'										do query_json { URI.unescape(params[:query]) } end

# The End
