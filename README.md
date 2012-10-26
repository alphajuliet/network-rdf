# network-rdf

Adventures in RDF and social connections with Ruby.

# Running 4store

```
	$ 4s-backend-setup test
	$ 4s-backend test
	$ 4s-httpd -p 8000 test
```

or with `rake rdfstore:start`.


# To-do

- Look at implications (via Pellet?)
- Match up LinkedIn and Contacts people through implication
- Use the [rel][] vocabulary to express relationships.
  - Note that these relationships don't all have inverses.
- Process custom RDF in the Notes field
- Visualise my address book in a browser

## Backlog

## In Progress

## On Hold

- Export LinkedIn data to compatible RDF (subject to throttling limits)

## Done

- Refactored VCard processor to use event model
- Load all contacts into 4store
- Export address book connections in RDF
- Export the basic profile as RDF
- Cache basic_profile call to speed up unit testing
- Move testing to RSpec.
- Cache the expensive call for connections from LinkedIn.
- Set up relative cache directory to source file

[rel]: http://vocab.org/relationship/.html
