require 'rake'
require 'echoe'

desc "Run tests hypothetically"
task :default => :test

version = File.read( 'VERSION' ) rescue "0.0.42_sakbug"

#################
# Deploy the gem 'sakuric'
Echoe.new('sakuric', version ) do |p|
  p.description    = "My SAKURA gem with various utilities. This is my swiss-army knife for Linux and Mac. See README.md for amazing examples"
  p.url            = "http://github.com/palladius/sakura"
  p.author         = "Riccardo Carlesso"
  p.email          = "['p','ll','diusbonton].join('a') @ gmail.com"
  p.ignore_pattern = [
    "tmp/*", 
    "tmp/*", #"tmp/*/*", "tmp/*/*/*",
    "private/*",
    ".noheroku",
    '.travis.yml',
  ]
  p.development_dependencies = [ 'ric','echoe' ]
  p.runtime_dependencies     = [ 'ric' ]
end

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

