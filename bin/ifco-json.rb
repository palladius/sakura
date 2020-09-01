#!/usr/bin/env ruby

require 'json'

curled_json = `curl https://ifconfig.co/json`

h = JSON.parse(curled_json)
h.keys.each do |k|
  print "#{ k}: #{h[k]} \n"
end


