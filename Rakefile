require 'rake'

desc "Run tests hypothetically"
task :default => :test

#Rake::TestTask.new do |t|
# t.libs << 'test'
#end

namespace :test do
	desc "Run mini tests"
	puts 'Rake test being executed...'
	Dir['test/*.rb'].each do |file|
		system "ruby #{file}"
	end
	Dir['test/*.sh'].each do |file|
		system "#{file}"
	end
end

#begin
#  require 'rspec/core/rake_task'             
#rescue LoadError
#  require 'rubygems'
#  retry
#end

#RSpec::Core::RakeTask.new(:spec) do |t|
#  t.pattern = 'spec/*_spec.rb'
#end

#task :test => [:spec]

#return 0
