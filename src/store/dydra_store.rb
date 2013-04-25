#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..")
$:.unshift File.dirname(__FILE__)

require 'config'
require 'rest_client'
require 'rdf_store'
require 'dydra'

class DydraStore < RdfStore

    def initialize
        @config = MyConfig.get["dydra"]
		Dydra.setup!(:token => @config["token"])
		account = Dydra::Account.new('alphajuliet')
		@repo = account[@config["repo-name"]]
    end

    def size
        @repo.count
    end

    def clear_all
		@repo.clear!
    end

    def load(statements)
		repo.import!(statements)
    end

end

# The End
