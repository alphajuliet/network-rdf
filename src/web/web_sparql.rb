#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "..", "src")
require 'sinatra'
require 'markaby'
require 'sparql_client'
require 'my_prefixes'
require 'json'
require 'web/sparql_queries'

helpers SparqlQueries

get '/' 											do markaby :home end
get '/people/all' 						do cmd_people_all end
get '/people/at/:orgname' 		do cmd_people_at_orgname end
get '/person/:name' 					do cmd_person_name end
get '/org/count_by_person' 		do cmd_org_count_by_person end
get '/no-email' 							do cmd_no_email end
get '/people/duplicates'			do cmd_people_duplicates end
get '/viz' 										do markaby :viz  end

# The End
