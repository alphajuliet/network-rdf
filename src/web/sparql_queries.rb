#!/usr/bin/env ruby

module SparqlQueries

	def query(&block)
		client = SPARQL::Client.new(MyConfig.get('sparql-endpoint'))
		query = yield
		client.query(RDF.Prefixes(:sparql) + query)
	end

	def query_and_render_on(template, &block)
		render_on(template, query(&block))
	end

	#----------------------------------------
	# All the specific SPARQL queries
	def cmd_people_names
		query do
			"SELECT DISTINCT ?name
			WHERE {
				?p a foaf:Person .
				?p foaf:name ?name .
			}
			ORDER BY ?name"
		end
	end
	
	def cmd_org_people
		query do 
			"SELECT ?name
			WHERE {
				?m a org:Membership .
				?m org:organization [ skos:prefLabel \'#{params[:orgname]}\'] .
				?m org:member [ foaf:name ?name ] .
			} 
			ORDER by ?name"
		end
	end
		
	def cmd_person_knows
		query do
			"SELECT DISTINCT ?name 
			WHERE {
				{
					?a foaf:name ?name .
					?a foaf:knows [ foaf:name \'#{params[:name]}\' ] .
				}
				UNION
				{
					?c foaf:name \'#{params[:name]}\' .
					?c foaf:knows [ foaf:name ?name ] .
				}
			}"		
		end
	end
	
	def cmd_person_card
		query do
			"SELECT ?property ?value
			WHERE {
				?a foaf:name \'#{params[:name]}\'.
				?a gldp:card ?card .
				{
					?card ?property [ rdf:value ?value ] .
				}
				UNION 
				{ 
					?card ?property [ v:locality ?value ] .
				}
				UNION
				{
					?a ?property [ foaf:accountName ?value ] .
				}
				UNION
				{
					?a ?property ?value .
					FILTER isIRI(?value)
				}
			}"
		end
	end
	
	def cmd_person_org
		query do
			"SELECT ?name
			WHERE {
				?m a org:Membership .
				?m org:organization [ skos:prefLabel ?name ] .
				?m org:member [ foaf:name \'#{params[:name]}\' ].
			}"
		end		
	end
	
	def cmd_org_count_by_person
		min = params["min"] || 0;
		query do
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
	
	def cmd_people_knows
		query do
			"SELECT ?source ?target
			WHERE {
				?a foaf:name ?source .
				?a foaf:knows [ foaf:name ?target ] .
				FILTER (?source != 'Andrew Joyner')
				FILTER (?target != 'Andrew Joyner')
			}"
		end
	end
	
	def cmd_no_email
		query do
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
