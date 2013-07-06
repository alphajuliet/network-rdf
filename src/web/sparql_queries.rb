#!/usr/bin/env ruby

module SparqlQueries

	def query_json(&block)
		query = yield
    store = Configuration.for('rdf_store').store
		response = RestClient.get Configuration.for(store).sparql, 
      :accept => 'application/sparql-results+json', 
      :params => { :query => RDF.Prefixes(:sparql) << query }
		response		
	end
	
	def query_and_render_on(template, &block)
		render_on(template, query(&block))
	end

	#----------------------------------------
	# All the specific SPARQL queries
	def cmd_people_names
		query_json do
			"SELECT DISTINCT ?name
			WHERE {
				?p a foaf:Person .
				?p foaf:name ?name .
			}
			ORDER BY ?name"
		end
	end
	
	def cmd_org_people
		query_json do 
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
		query_json do
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
		query_json do
			"SELECT ?property ?value
			WHERE {
				?a foaf:name \'#{params[:name]}\'.
				{
					?a ?property [ rdf:value ?value ] .
				}
				UNION 
				{ 
					?a ?property [ v:locality ?value ] .
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
        FILTER (?property != foaf:knows)
			}"
		end
	end
	
	def cmd_person_org
		query_json do
			"SELECT ?name
			WHERE {
        ?p foaf:name \'#{params[:name]}\' .
        {
          ?m a org:Membership .
          ?m org:organization [ skos:prefLabel ?name ] .
          ?m org:member ?p .
        }
        UNION
        {
          ?p net:workedAt [ skos:prefLabel ?name ] .
        }
        UNION
        {
          ?p net:worksAt [ skos:prefLabel ?name ] .
        }
			}"
		end		
	end
	
	def cmd_org_count_by_person
		min = params[:min] || 0;
		query_json do
			"SELECT ?orgname (COUNT (?p) AS ?members)
			WHERE {
				?m a org:Membership .
				?m org:organization [ skos:prefLabel ?orgname ] .
				?m org:member ?p .
			}
			GROUP BY ?orgname
			HAVING (COUNT (?p) >= #{min})
			ORDER BY DESC(?members)"
		end
	end
	
	def cmd_people_knows
		query_json do
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
		query_json do
			"SELECT ?name 
			WHERE {
        ?p v:fn ?name .
				OPTIONAL { 
					?p v:hasEmail ?e.
				}
				FILTER (!bound(?e))
			}"
		end		
	end
	
end

# The End
