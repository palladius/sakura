require 'rake'
require 'echoe'

version = File.read( 'VERSION' ) rescue "0.0.42_sakbug"

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
