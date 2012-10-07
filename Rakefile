#!/usr/bin/env rake

# Set up unit testing
# See <http://martinfowler.com/articles/rake.html>
require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test_*.rb']
  t.verbose = false
  t.warning = true
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

# The End
