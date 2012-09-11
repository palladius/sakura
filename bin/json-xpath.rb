#!/usr/bin/env ruby

class String
  def is_number?
    true if Float(self) rescue false
  end
end

python_program = "import sys, json; print json.load(sys.stdin)['networkInterface'][0]['accessConfiguration'][0]['externalIp'] "
args = ARGV.map { |arg| is_number?(arg.to_s) ? arg.to_s : "'" + arg + "'" }.join('][')

puts python_program
puts args
