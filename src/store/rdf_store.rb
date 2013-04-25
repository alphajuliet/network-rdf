#!/usr/bin/env ruby

class RdfStore

    def initialize

    end

    def clear_all

    end

    def size

    end

    def load

    end

    def load_from_file(f)
        self.load(File.open(f).read)
    end

    def add(triples)

    end

    def add_from_file(f)
        self.add(File.open(f).read)
    end

end
