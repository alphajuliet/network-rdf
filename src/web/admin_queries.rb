#!/usr/bin/env ruby

module AdminQueries

	def cmd_repo
    rdf_store = eval(Configuration.for('rdf_store').class_name + ".new")
    rdf_store.size
	end

end

# The End
