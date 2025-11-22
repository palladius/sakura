

desc "Run tests on Gems but it doesnt work"

namespace :gemtests do
    desc "Gemfile tests"
    puts 'Rake test being executed...'
    gems_to_be_tested = %w{ ric google-cloud-logging  }
    gems_to_be_tested.each_with_index do |gemname, ix|
        pwhite "[#{ix}] Assert gem '#{gemname}' is installed.."

        output = `gem list | grep -q '#{gemname}' ; echo $?`
        deb "DEB: #{output}"
        ret = Integer(output) rescue 42

        puts "Return: #{ret}"
        if ret == 0
            pgreen "[#{ix}] Gem '#{gemname}' found :)"
        else
            prosso "[#{ix}] Gem '#{gemname}' not found"
            exit 42 
        end
    end
    return 0
end

task :default => :gemtests

# exit 42


