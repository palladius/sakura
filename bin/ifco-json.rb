#!/usr/bin/env ruby

require 'json'

curled_json = `curl https://ifconfig.co/json`

h = JSON.parse(curled_json) rescue {'JSONImportRiccError': "Riccardo Error importing JSON (#{$!})"}
h.keys.each do |k|
  print "#{ k}: #{h[k]} \n"
end


