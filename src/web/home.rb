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

helpers SparqlQueries, AdminQueries

get '/' 											do markaby :home end
get '/people/all'							do cmd_people_all end
get '/people/knows'						do cmd_people_knows end
get '/people/at/:orgname' 		do cmd_people_at_orgname end
get '/person/:name' 					do cmd_person_name end
get '/person/:name/knows'			do cmd_person_knows end
get '/org/count_by_person' 		do cmd_org_count_by_person end
get '/no-email' 							do cmd_no_email end
get '/viz' 										do markaby :viz  end
get '/repo'										do cmd_repo end

# The End
