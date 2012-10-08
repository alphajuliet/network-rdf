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

- linkedin
- rspec
- rdf
- rdf-turtle
- rake

# To-do

## Backlog

- Export a connection in RDF/Turtle

## In Progress

## Done

- Export the basic profile as RDF
- Cache basic_profile call to speed up unit testing
- Move testing to RSpec.
- Cache the expensive call for connections from LinkedIn.
- Set up relative cache directory to source file


