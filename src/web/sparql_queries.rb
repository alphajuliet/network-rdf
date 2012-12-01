#!/usr/bin/env ruby

module SparqlQueries

	def to_json(query_result)
		array = []
		query_result.each_solution do |solution|
			hash = Hash.new
			solution.each_binding { |name, value| hash[name] = value.to_s }
			array << hash
		end
		JSON.pretty_generate(array)
	end	

	def query(&block)
		client = SPARQL::Client.new(MyConfig.get('sparql-endpoint'))
		query = yield
		client.query(RDF.Prefixes(:sparql) + query)
	end
	
	def query_type(*types, &block)
		h = Hash.new
		h[:result] = query(&block)
		h[:types] = types
		h
	end
	
	def render_on(template, result)
		if request.accept.include?('text/html')
			markaby template, :locals => { :result => result } 
		elsif request.accept.include?('application/json')
			to_json(result)
		end
	end
	
	def query_and_render_on(template, &block)
		render_on(template, query(&block))
	end
	
	#----------------------------------------
	# All the specific SPARQL queries
	def cmd_people_names
		query_and_render_on(:query1) do
			"SELECT ?name
			WHERE {
				?p a foaf:Person .
				?p foaf:name ?name .
			}
			ORDER BY ?name"
		end
	end
	
	def cmd_people_all
		query_and_render_on(:query1) do
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
		query_and_render_on(:query1) do 
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
		query_and_render_on(:query1) do
			"SELECT DISTINCT ?prop ?value 
			WHERE {
				?a foaf:name \'#{params[:name]}\'.
				?a gldp:card ?card .
				{
					?card ?prop ?o .
					?o rdf:value ?value .
				}
				UNION {
					?card ?prop [ v:locality ?value ] .
				}
				UNION {
					?a ?prop [ foaf:accountName ?value ] .
				}
				UNION {
					?a ?prop [ skos:prefLabel ?value ] .
				}
				UNION {
					?a ?prop ?value .
					FILTER isIRI (?value) .
				}
				UNION
				{
					?a ?prop [ a foaf:Person; foaf:name ?value ] .
					FILTER (?prop = foaf:knows)					
				}
				UNION
				{
					?b foaf:name ?value .
					?b ?prop ?a .
					FILTER (?prop = foaf:knows)
				}
			}"
		end	
	end
	
	def cmd_person_name1
		results = []
		results << query do
			"SELECT DISTINCT ?prop ?value 
			WHERE {
				?a foaf:name \'#{params[:name]}\'.
				?a gldp:card ?card .
				?card ?prop ?o .
				?o rdf:value ?value .
			}"
		end
		results << query do
			"SELECT DISTINCT ?prop ?value
			WHERE {
				?a foaf:name \'#{params[:name]}\'.
				?a gldp:card ?card .
				?card ?prop [ v:locality ?value ] .
			}"
		end
		results << query do
			"SELECT DISTINCT ?prop ?value
			WHERE {
				?a foaf:name \'#{params[:name]}\'.
				?a gldp:card ?card .
				?a ?prop [ foaf:accountName ?value ] .
			}"
		end
		
		render_on(:person, results)
	end
	
	def cmd_person_knows
		query_and_render_on(:query1) do
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
		query_and_render_on(:query1) do
			"SELECT ?prop ?value
			WHERE {
				?a foaf:name \'#{params[:name]}\'.
				?a gldp:card ?card .
				{
					?card ?prop [ rdf:value ?value ] .
				}
				UNION 
				{ 
					?card ?prop [ v:locality ?value ] .
				}
			}"
		end
	end
	
	def cmd_org_count_by_person
		min = params["min"] || 0;
		query_and_render_on(:query1) do
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
		query_and_render_on(:query1) do
			"SELECT ?source ?target
			WHERE {
				?a foaf:name ?source .
				?a foaf:knows [ foaf:name ?target ] .
			}"
		end
	end
	
	def cmd_no_email
		query_and_render_on(:query1) do
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
