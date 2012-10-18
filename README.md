# network-rdf

Adventures in RDF and social connections with Ruby.

# Example RDF graph
```
	@prefix foaf: <...> .
	@prefix org: <...> .
	@prefix owl: <...> .
	@prefix aj: <http://alphajuliet.com/ns/people#> .
	@prefix linkedin: <http://www.linkedin.com/people/> .

	aj:andrewj owl:sameAs <http://au.linkedin.com/in/andrewjoyner> .

	aj:andrewj foaf:knows <http://au.linkedin.com/pub/john-smith/53/4a4/307> .
	<http://au.linkedin.com/pub/john-smith/53/4a4/307> 
		foaf:name "John Smith" ;
		foaf:email "mailto:john.smith@example.com" ;
		...
```

## Required gems

- linkedin 0.3.7
- rspec 2.11.0
- rdf 0.3.8
- rdf-turtle 0.1.2
- rdf-json 0.3.0
- rake 0.9.2.2
- rest-client 1.6.7

# To-do

- Export connections in JSON
- Visualise companies in a graph in the browser

## Backlog

- Export a connection in RDF/Turtle

## In Progress

## Done

- Export the basic profile as RDF
- Cache basic_profile call to speed up unit testing
- Move testing to RSpec.
- Cache the expensive call for connections from LinkedIn.
- Set up relative cache directory to source file


