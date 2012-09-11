#!/usr/bin/env ruby

# try also the Oauth playground:
# http://googlecodesamples.com/oauth_playground/

$default_arg = "networkInterface.0.accessConfiguration.0.externalIp"

class String
  def is_number?
    true if Float(self) rescue false
  end
end


def usage
	print "Usage: #{$0} <xpath>
Example: #{$0} #{ $default_arg } # this will find your public IP from GCE metadata
	(Try to use this in pipe with 'curl http://metadata.google.internal/0.1/meta-data/network' "
	exit(1)
end

def process_args(dotted_arg)
  arr_args = dotted_arg.split '.'
	python_program_original = "import sys, json; print json.load(sys.stdin)['networkInterface'][0]['accessConfiguration'][0]['externalIp'] "
	python_program = "import sys, json; print json.load(sys.stdin)"
	args = arr_args.map { |arg| arg.to_s.is_number? ? arg.to_s : "'" + arg + "'" }.map{|x| "[#{x}]" }
	my_program = python_program + args.join('')

	puts python_program_original
	puts my_program
end
	
def main
	#print 'argv[0]: ', ARGV[0] , "\n"
	usage unless ARGV[0]
	process_args(ARGV[0])
end

main()
