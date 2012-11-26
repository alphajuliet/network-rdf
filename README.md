# network-rdf

Adventures in RDF and social connections with Ruby.

# Activity

Check the [Trello board][trello].

[trello]: https://trello.com/board/network-rdf/508b13849712d34924002b86

# Issues

## Relationships

The mapping problem for relationships is twofold:

1. There are groups
2. There is custom and inconsistent tagging of entries

Examples and desired output (assuming my standard prefixes):

	URL;type=WORK;type=pref:http://www.example.org/
	--> ajc:person-xxxx foaf:page <http://www.example.org/> .

	The above result is because we cannot detect type=WORK from the vCard gem.
	
	URL;type=HOME;type=pref:http://www.example.org/
	--> ajc:person-xxxx foaf:homepage <http://www.example.org/> .

	item1.URL:http://jane.smith.name/
	item1.X-ABLabel:_$!<HomePage>!$_
	--> ajc:person-xxxx foaf:homePage <http://jane.smith.name/>
	
	item2.URL:http://www.example.org/janesmith/profile
	item2.X-ABLabel:profile
	--> ajc:person-xxxx rdfs:seeAlso <http://www.example.org/janesmith/profile>

	item3.X-ABRELATEDNAMES;type=pref:John Smith
	item3.X-ABLabel:_$!<Spouse>!$_
	--> ajc:person-xxxx foaf:knows [ a foaf:Person ; foaf:name "John Smith" ] .
	
	item5.X-ABRELATEDNAMES:Oracle Australia
	item5.X-ABLabel:net:workedAt
	--> ajc:person-xxxx net:workedAt [ a org:Organization ; skos:prefLabel "Oracle Australia" ] .
	
	item7.X-ABRELATEDNAMES:Alice Jones
	item7.X-ABLabel:foaf:knows
	--> ajc:person-xxxx foaf:knows [ a foaf:Person ; foaf:name "Alice Jones" ] .


