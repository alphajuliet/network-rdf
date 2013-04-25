#!/usr/bin/env ruby

require 'yaml'

class MyConfig
		
	def MyConfig.get
        # Lazy initialisation
		if @config.nil?
			@config = YAML.load(
				File.open(
					File.join(
						File.dirname(__FILE__), 
						"config.yaml")))
		end
		@config
	end
	
end

# The End
