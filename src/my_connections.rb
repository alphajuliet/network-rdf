#!/usr/bin/env ruby

require 'my_linked_in'

class MyConnections
	
	def initialize
		@connections = []
	end
	
	def MyConnections.new_from_LinkedIn
		l = MyLinkedIn.new
		@connections = l.connections
	end
	
	def size
		@connections.size
	end
	
end

# The End
