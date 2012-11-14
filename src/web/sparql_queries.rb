#!/usr/bin/env ruby

module SparqlQueries

	# Convert a solution to JSON format
	def to_json(query_result)
		array = []
		query_result.each_solution do |solution|
			hash = Hash.new
			solution.each_binding { |name, value| hash[name] = value.to_s }
			array << hash
		end
		JSON.pretty_generate(array)
	end	

	# Do the SPARQL query and render on the given template, or return as JSON
	# @@todo Refactor this method
	def query(template=:query1, &block)
		client = SPARQL::Client.new('http://localhost:8000/sparql/')
		query = yield
		result = client.query(RDF.Prefixes(:sparql) + query)
		if request.accept.include?('text/html')
			markaby template, :locals => { :result => result } 
		elsif request.accept.include?('application/json')
			to_json(result)
		end		
	end
		
	def cmd_people_all
		query(:query1) do
			"SELECT ?name ?orgname
			WHERE {
				?m a org:Membership .
				?m org:member [ foaf:name ?name ] .
				?m org:organization [ skos:prefLabel ?orgname ] .
			}
			ORDER BY ?orgname"
		end 
	end

	def cmd_people_duplicates
		query(:query1) do
			"SELECT ?name ?x ?y
			WHERE {
				?x foaf:name ?name .
				?y foaf:name ?name .
				FILTER (?x < ?y)
			}
			ORDER BY ?name"
		end
	end
	
	def cmd_people_at_orgname
		query(:query1) do 
			"SELECT ?name 
			WHERE {
			?m a org:Membership .
			?m org:organization ?org .
			?org skos:prefLabel \'#{params[:orgname]}\' .
			?m org:member ?p .
			?p foaf:name ?name .
			} 
			ORDER by ?name"
		end
	end
	
	def cmd_person_name
		query(:query1) do
			"SELECT ?predicate ?object
			WHERE {
				?p foaf:name \'#{params[:name]}\' .
				?p ?predicate ?object .
			}"
		end		
	end
	
	def cmd_org_count_by_person
		min = params["min"] || 0;
		query(:query1) do
			"SELECT ?orgname (COUNT (?p) AS ?members)
			WHERE {
				?m a org:Membership .
				?m org:organization ?org .
				?org skos:prefLabel ?orgname .
				?m org:member ?p .
			}
			GROUP BY ?orgname
			HAVING (COUNT (?p) >= #{min})
			ORDER BY DESC(?members)"
		end
	end
	
	def cmd_no_email
		query(:query1) do
			"SELECT ?name 
			WHERE {
				?card a v:VCard ;
							v:fn ?name .
				OPTIONAL { 
					?card v:email ?e.
				}
				FILTER (!bound(?e))
			}"
		end		
	end
	
end

# The End
