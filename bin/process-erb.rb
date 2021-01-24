#!/usr/bin/env ruby
## taken from: https://gist.github.com/troykinsella/a8c1bb5634a2bb624abb848e36c483a6#file-process-erb-rb-L21 

require 'erb'
require 'yaml'

class HashBinding
  def initialize(hash)
    @hash = hash.dup
  end
  def method_missing(m, *args, &block)
    @hash[m.to_s]
  end
  def get_binding
    binding
  end
end

t = ERB.new(File.read(ARGV[0]))
vars = YAML.load_file(ARGV[1])
b = HashBinding.new(vars)
puts t.result(b.get_binding)
