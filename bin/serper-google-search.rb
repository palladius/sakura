#!/usr/bin/env ruby

require "uri"
require "json"
require "net/http"

SERPER_API_KEY = ENV.fetch('SERPER_API_KEY',nil)
$stderr.puts("Note:  this API KEY has a monthly cap. Consider doing some caching and using sparingly.")
$stderr.puts("Tip: Try feeding STDOUT to `jq` for nicer output.")
raise "ENV[SERPER_API_KEY] not provided! Get one here://serper.dev/" unless SERPER_API_KEY

url = URI("https://google.serper.dev/search")

https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

request = Net::HTTP::Post.new(url)
request["X-API-KEY"] = SERPER_API_KEY
request["Content-Type"] = "application/json"
request.body = JSON.dump({
  "q": "Riccardo Carlesso"
})

response = https.request(request)
puts response.read_body
