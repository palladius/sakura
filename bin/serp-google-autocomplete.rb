#!/usr/bin/env ruby

# Ricc figata! copiato da SERP.com
#  https://serpapi.com/playground?engine=google_flights&departure_id=ZRH&arrival_id=AMS&hl=it&currency=CHF&outbound_date=2024-01-01&return_date=2024-01-05&adults=2&stops=1
require 'google_search_results'
require 'rainbow'

# params = {
#   api_key: "YOUR_SERP_API_KEY",
#   engine: "google_flights",
#   hl: "it",
#   departure_id: "ZRH",
#   arrival_id: "AMS",
#   outbound_date: "2024-01-01",
#   return_date: "2024-01-05",
#   currency: "CHF",
#   adults: "2",
#   stops: "1"
# }

# search = GoogleSearch.new(params)
# hash_results = search.get_hash
#
def _yellow(s)
  "\033[1;33m#{s}\033[0m"
end
def _red(s)
  Rainbow(s).red.bold # "\033[1;33m#{s}\033[0m"
end
require 'google_search_results'

SERP_API_KEY = ENV.fetch 'SERP_API_KEY', nil
raise('Missing ENV["SERP_API_KEY"].. failing.') unless SERP_API_KEY

default_query = "salsa ai q"
query = ARGV.size == 0 ? default_query : ARGV.join(' ')

params = {
  api_key: SERP_API_KEY,
  engine: "google_autocomplete",
  q: query
}
puts _red('Implement caching like in serp-*-cached.rb (or btw move to a library/code repo on its own)')
puts "👀 Searching for autocompletion for '#{query}'.."

search = GoogleSearch.new(params)
hash_results = search.get_hash

hash_results[:suggestions].each do |h|
  # {:value=>"salsa ai quattro formaggi", :relevance=>1250, :type=>"QUERY", :serpapi_link=>"https://serpapi.com/search.json?engine=google_autocomplete&q=salsa+ai+quattro+formaggi"}
  puts "  🎄 [#{h[:relevance]}]\t#{_yellow h[:value]}"
end




# require 'google_search_results'

# params = {
#   api_key: "YOUR_SERP_API_KEY",
#   engine: "google_images",
#   google_domain: "google.com",
#   q: "avocado shirt",
#   hl: "en",
#   gl: "us"
# }

# search = GoogleSearch.new(params)
# hash_results = search.get_hash
