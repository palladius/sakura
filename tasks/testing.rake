
desc "Run tests but it doesnt work :/"

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

# task :default => :rictest
