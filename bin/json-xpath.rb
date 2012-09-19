#!/usr/bin/env ruby

=begin

Try also the Oauth playground: http://googlecodesamples.com/oauth_playground/

Solves this problem with GCE. It was:

	curl -s http://metadata/0.1/meta-data/network | python -c "import sys,json; print json.load(sys.stdin)['networkInterface'][0]['accessConfiguration'][0]['externalIp']"

 It becomes:

	curl -s http://metadata/0.1/meta-data/network |json-xpath.rb networkInterface.0.accessConfiguration.0.externalIp

=end
$default_arg = "networkInterface.0.accessConfiguration.0.externalIp"

class String
  def is_number?
    true if Float(self) rescue false
  end
end


def usage
	print "Usage: #{$0} <xpath>

Example: #{$0} #{ $default_arg } # this will find your public IP from GCE metadata
	(Try to use this in pipe with 'curl http://metadata.google.internal/0.1/meta-data/network' 
"
	exit(1)
end

def process_args(dotted_arg)
  arr_args = dotted_arg.split '.'
	python_program_original = "import sys, json; print json.load(sys.stdin)['networkInterface'][0]['accessConfiguration'][0]['externalIp'] "
	python_program = "import sys, json; print json.load(sys.stdin)"
	args = arr_args.map { |arg| arg.to_s.is_number? ? arg.to_s : "'" + arg + "'" }.map{|x| "[#{x}]" }
	my_program = python_program + args.join('')

	cmd_exec = "/usr/bin/python -c \"#{my_program}\" 2>/dev/null"
	myin = $stdin.read
	%x( #{cmd_exec} )
	IO.popen(cmd_exec, mode='w') do |io|
		io.write(myin)
	end
end
	
def main
	usage unless ARGV[0]
	process_args(ARGV[0])
end

main()
