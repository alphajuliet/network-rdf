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
	def query(template=:query1, &block)
		client = SPARQL::Client.new(MyConfig.get('sparql-endpoint'))
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
			"SELECT ?name ?orgname ?mobile ?email
			WHERE {
				?m a org:Membership .
				?m org:organization [ skos:prefLabel ?orgname ] .
				?m org:member ?p .
				?p foaf:name ?name .
				?p gldp:card ?card .
				OPTIONAL { ?card v:tel [ a v:cell; rdf:value ?mobile ] .}
				OPTIONAL { ?card v:email [ a v:home; rdf:value ?email ] . }
			}
			ORDER BY ?name"
		end 
	end

	def cmd_people_at_orgname
		query(:query1) do 
			"SELECT ?name ?mobile
			WHERE {
				?m a org:Membership .
				?m org:organization ?org .
				?org skos:prefLabel \'#{params[:orgname]}\' .
				?m org:member ?p .
				?p foaf:name ?name .
				OPTIONAL {
					?p gldp:card ?card .
					?card v:tel ?tel .
					?tel a v:cell .
					?tel rdf:value ?mobile .
				}
			} 
			ORDER by ?name"
		end
	end
	
	def cmd_person_name
		query(:query1) do
			"SELECT ?mobile ?email
			WHERE {
				?p foaf:name \'#{params[:name]}\' .
				?p gldp:card ?card .
				OPTIONAL { ?card v:tel [ a v:cell; rdf:value ?mobile ] .}
				OPTIONAL { ?card v:email [ a v:home; rdf:value ?email ] . }
			}"
		end		
	end
	
	def cmd_person_knows
		query(:query1) do
			"SELECT DISTINCT ?name 
			WHERE {
				{
					?a a foaf:Person .
					?a foaf:name ?name .
					?a foaf:knows ?b .
					?b foaf:name \'#{params[:name]}\' .
				}
				UNION
				{
					?c foaf:name \'#{params[:name]}\' .
					?c foaf:knows ?d .
					?d foaf:name ?name .
				}
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
