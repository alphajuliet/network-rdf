#!/usr/bin/env ruby

class RdfStore

    def initialize

    end

    def clear_all
        raise "Error: Subclass method not implemented."
    end

    def size
        raise "Error: Subclass method not implemented."
    end

    def load
        raise "Error: Subclass method not implemented."
    end

    def load_from_file(f)
        self.load(File.open(f).read)
    end

    def add(triples)
        raise "Error: Subclass method not implemented."
    end

    def add_from_file(f)
        self.add(File.open(f).read)
    end

end
