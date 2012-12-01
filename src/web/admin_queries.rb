#!/usr/bin/env ruby

module AdminQueries

	def cmd_repo
		api_key = "pH9iszmNQWav1k0RZZYA"
		repo_api = "http://#{api_key}@api.dydra.com/"
		response = RestClient.get repo_api + "alphajuliet/network-rdf/meta", :accept => "application/json"
		@data = JSON.parse(response.to_str)
	end

end

# The End
