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

def render_on(template, result)
	if request.accept.include?('text/html')
		markaby template, :locals => { :result => result } 
	elsif request.accept.include?('application/json')
		to_json(result)
	end
end

#------------------------------
get '/' 												do markaby :home end
get '/people/all'								do render_on(:query1, cmd_people_all) end
get '/people/names'							do render_on(:query1, cmd_people_names) end
get '/people/knows'							do render_on(:query1, cmd_people_knows) end
get '/person/:name' 						do markaby :person end
get '/org/:orgname/people' 			do render_on(:organisation, cmd_org_people) end
get '/org/count_by_person' 			do render_on(:query1, cmd_org_count_by_person) end
get '/no-email' 								do render_on(:query1, cmd_no_email) end
get '/viz/org/count_by_person'	do markaby :viz1 end
get '/viz/people/knows'					do markaby :viz2 end
get '/repo'											do cmd_repo end

# Data only, no view
get '/person/:name/knows'				do cmd_person_knows end
get '/person/:name/card'				do cmd_person_card end
get '/person/:name/org'					do cmd_person_org end

# The End
