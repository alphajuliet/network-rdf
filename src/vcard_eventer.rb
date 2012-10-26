#!/usr/bin/env ruby

require 'rubygems'
require 'vpim/vcard'

class VCardEventer

	def initialize(vcard)
		@vcard = vcard
	end
		
	def process
		@vcard.lines.each do |line|
			self.send("do_" + line.name.downcase.tr('-', '_'), line.value)
		end
	end

=begin
	def do_version(value)
		puts "Version: #{value}"
	end
=end
	
	def method_missing(name, *args)
		# puts "#{name}: #{args.inspect}"
	end

end

# Usage: VCardEventer.new(card).process

# The End
