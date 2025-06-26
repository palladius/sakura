#!/usr/bin/env ruby

# Ricc figata! copiato da SERP.com
#  https://serpapi.com/playground?engine=google_flights&departure_id=ZRH&arrival_id=AMS&hl=it&currency=CHF&outbound_date=2024-01-01&return_date=2024-01-05&adults=2&stops=1
require 'google_search_results'
require 'rainbow'

SERP_API_KEY = ENV.fetch 'SERP_API_KEY', nil
raise('Missing ENV["SERP_API_KEY"].. failing.') unless SERP_API_KEY

DEFAULT_ARRIVAL_AIRPORT = 'OPO' # Oporto
# "SJJ", # Sarajevo

$DEBUG = false

def _yellow(s)
  # Todo use Rainbow
  "\033[1;33m#{s}\033[0m"
end
def _red(s)
  Rainbow(s).red.bold # "\033[1;33m#{s}\033[0m"
end

puts _red('Implement caching like in serp-*-cached.rb (or btw move to a library/code repo on its own)')
puts _yellow('Ricc todo aggiungi un Tool a Langchain che fa Aeroporti e Hotel.. nell ordine.')
tomorrow = (Date.today + 1).to_s
in_8_days = (Date.today + 8).to_s
puts(_yellow("Searching for best flights through SerpAPI from tomorrow #{tomorrow} and return in 7 days"))
params = {
  api_key: SERP_API_KEY,
  engine: "google_flights",
  departure_id: "ZRH",
  arrival_id: DEFAULT_ARRIVAL_AIRPORT,
  outbound_date: tomorrow, #  "2024-09-12", # tomorrow
  return_date: in_8_days,
  currency: "USD",
  hl: "en",
  q: 'pioggia',
}

def format_flight_duration_with_m(minutes)
  hours = minutes / 60
  remaining_minutes = minutes % 60
  formatted_string = ""

  formatted_string << "#{hours}h" if hours > 0
  formatted_string << "0#{remaining_minutes}m" if remaining_minutes < 10
  formatted_string << "#{remaining_minutes}m" if remaining_minutes >= 10

  formatted_string.empty? ? "0m" : formatted_string
end
# Omitting final m
def format_flight_duration(minutes)
  hours = minutes / 60
  remaining_minutes = minutes % 60
  formatted_string = ""

  formatted_string << "#{hours}h" if hours > 0
  formatted_string << "0#{remaining_minutes}" if remaining_minutes < 10 && hours > 0
  formatted_string << "#{remaining_minutes}" if remaining_minutes >= 10 && hours > 0
  formatted_string << "#{remaining_minutes}m" if remaining_minutes > 0 && hours == 0

  formatted_string.empty? ? "0m" : formatted_string
end

def sanitize_airport_name(name)
  name.gsub(/Airport/, '').gsub(/International/, '').chomp
end

def print_flight_with_legs(ix, h) # h is flight
  puts "#{ix} ✈️ Best flight: #{h.except :flights}" if $DEBUG
  total_duration = format_flight_duration(h[:total_duration])
  price = h[:price]
  #{:layovers=>[{:duration=>50, :name=>"Frankfurt Airport", :id=>"FRA"}],
  layovers = (h[:layovers] or []).map{|h| "#{format_flight_duration h[:duration]} @#{h[:id]}"}

  layover_string = layovers.count == 0 ?
    '👍 Direct' :
    "#{layovers.count} layover (#{layovers.join(', ')})"

  puts(_yellow("✈️ Flight ##{ix}: #{price}$ Tot⏱️ #{total_duration}m, #{layover_string}"))
  h[:flights].each_with_index do |flight,ix|
    # LEG🦵
    departure = flight[:departure_airport][:id]
    duration = format_flight_duration flight[:duration]
    airline = flight[:airline]
    travel_class = flight[:travel_class].gsub('Economy', '') # default -> nil
    dest = sanitize_airport_name flight[:arrival_airport][:name]
    flugzeug = flight[:airplane]
    #puts flight
    str ="  🦵 #{flight[:departure_airport][:time]} #{flight[:flight_number].gsub(' ','')} #{departure} => #{flight[:arrival_airport][:id]} (#{duration}) #{airline} #{travel_class} #{flugzeug} to #{dest}"
    puts(str)
  end
end
search = GoogleSearch.new(params)
hash_results = search.get_hash
puts(hash_results) if $DEBUG
#puts _yellow(hash_results.keys)
# search = GoogleSearch.new(params)
# hash_results = search.get_hash
best_flights = hash_results.dig(:best_flights)
puts("== #{best_flights.count} Best flights ==" )
best_flights.each_with_index do |h,ix|
  print_flight_with_legs(ix, h)

end
puts("Other flights: #{hash_results.dig(:other_flights).count}")
hash_results.dig(:other_flights).each_with_index do |flight,ix|
#  puts(flight)
  print_flight_with_legs(ix, flight)
end
puts("💙 JSON Endpoint: #{hash_results[:search_metadata][:json_endpoint]}")
puts("🥶 Created at: #{hash_results[:search_metadata][:created_at]}")

puts("Riccardo only - created an alternative with better CLI interface in q")
# params = {
#   api_key: "YOUR_SERP_API_KEY",
#   engine: "google_autocomplete",
#   q: "salsa ai q"
# }

# puts params
# exit 42
# search = GoogleSearch.new(params)
# hash_results = search.get_hash

# hash_results[:suggestions].each do |h|
#   # {:value=>"salsa ai quattro formaggi", :relevance=>1250, :type=>"QUERY", :serpapi_link=>"https://serpapi.com/search.json?engine=google_autocomplete&q=salsa+ai+quattro+formaggi"}
#   puts "🎄 [#{h[:relevance]}]\t#{_yellow h[:value]}"
# end
