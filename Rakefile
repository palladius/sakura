require 'rake'
require 'echoe'
require 'ric'

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

# found here: http://jasonseifer.com/2010/04/06/rake-tutorial
file "hello.tmp" => "tmp" do
  sh "echo 'Hello' >> 'tmp/hello.tmp'"
end
