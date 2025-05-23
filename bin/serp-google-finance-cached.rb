#!/usr/bin/env ruby

# Ricc figata! copiato da SERP.com
#  https://serpapi.com/playground?engine=google_flights&departure_id=ZRH&arrival_id=AMS&hl=it&currency=CHF&outbound_date=2024-01-01&return_date=2024-01-05&adults=2&stops=1
require 'google_search_results'
require 'rainbow'
require 'digest'
require 'yaml'
require 'pry'
require 'byebug'


SERP_API_KEY = ENV.fetch 'SERP_API_KEY', nil
raise('Missing ENV["SERP_API_KEY"].. failing.') unless SERP_API_KEY

# Note: SPy doesnt work, probably as the default Nasdaq suffix wont work for it.
$sample_stocks = %w{ AAPL GOOG GOOGL NVDA NFLX TSLA SPY} # NYSEARCA:SPY
$prog_version = '1.1b'
$default_stock = 'GOOGL'
$stock_to_check = ARGV[0] || $default_stock
puts("🔧 Checking Stock: #{$stock_to_check}")

def cached_google_search(params, version=$prog_version)
  cache_key = Digest::MD5.hexdigest(params.to_s + $prog_version) # so it changes cache if you bump up version
  cache_file = ".cache/serp.finance.#{cache_key}.json"

  if File.exist?(cache_file)
    puts  Rainbow("[debug] Cache hit: #{cache_file}").green

    JSON.parse(File.read(cache_file))
  else
#    puts "[debug] Cache miss: #{cache_file}"
    puts  Rainbow("[debug] Cache miss (small bug, ): #{cache_file}").red
    search_result = GoogleSearch.new(params)
    # FIGATA GALATTICA
    #    binding.pry

    Dir.mkdir('.cache') unless Dir.exist?('.cache')

    File.open(cache_file, 'w') { |f| f.write(JSON.dump(search_result.get_hash)) }
#    search_result.get_hash # non va, credo :key vs 'key'
    JSON.parse(File.read(cache_file))
  end
end

def print_fancy_stock_line(x)
  return if x.nil?
  stock_name = x['name'] || x['stock']
  currency = x.fetch 'currency', '💲'
  mov_hash =x['price_movement']
  price_02 = x['price'].round(2) rescue x['price']
  # if mov_hash.nil?
  #   puts "🐞🐞🐞 EMPTY Movement #{x}"
  #print("mov_hash.keys = #{mov_hash.keys}")
  sign =  mov_hash['movement'] == 'Up' ? '+' : '-' rescue '🤷🏼‍♀️'
#  movement_val = mov_hash['percentage'].to_s.format('%02d', 4) rescue 4242
  movement_val = "#{sign}#{mov_hash['percentage'].round(2)}%" rescue '' # .to_s.format('%02d', 4) rescue 4242
  colored_movement = Rainbow(movement_val).send(mov_hash['movement'] == 'Up' ? :green : :red) rescue '🤷🏼‍♀️'
  puts "📈 #{stock_name}:\t #{price_02}#{currency}\t#{colored_movement}"
end

def print_news_snippet(n)
  if n['snippet']
    puts(" 🗞️  #{Rainbow(n['snippet']).yellow} (#{n['source']}, #{n['date']})")
  #else
    #puts("🐞🐞🐞 #{n}")
  end
end


params = {
  engine: "google_finance",
#  q: "GOOGL:NASDAQ",
  q: "#{$stock_to_check}:NASDAQ",
#  q: "GOOG", #158 e rotti
  api_key: SERP_API_KEY,
}

search = cached_google_search(params)
hash_results = search # .get_hash rescue search
#exit 42

puts("1. Markets:")
#binding.pry

hash_results['markets']['us'].each do |x|
  print_fancy_stock_line(x)
end

if $DEBUG
  puts("🐞 hash_results.keys: #{hash_results.keys.join ' '}")
  puts("🐞 hash_results.market.keys: #{hash_results['markets'].keys.join ' '}")
#puts("🐞 hash_results.market.us.keys: #{hash_results['markets']['us'].keys.join ' '}")
end
puts("2. Your stock info SUMMARY:")
puts hash_results['summary'] if $DEBUG
print_fancy_stock_line(hash_results['summary'])

# puts("3. Your MARKETS stock info:")
# puts hash_results['markets'].keys # ['summary']
puts("3. Market TopNews:")
#puts hash_results['markets']['top_news'].keys # ['summary']
#puts hash_results['markets']['top_news'] # .keys # ['summary']
# hash_results['markets']['top_news'].each do |article|
#   puts "📰  #{article}"
# end
# puts "📰  #{hash_results['markets']['top_news']['snippet']}"
n = hash_results['markets']['top_news']
print_news_snippet(n)
#puts("📰 #{Rainbow(n['snippet']).green} (#{n['source']}, #{n['date']})")

news_results = hash_results['news_results']
puts("4. News Results:")
(hash_results['news_results'] or []).each do |nr|
  title_or_snippet = nr.fetch('title', nr.fetch('snippet', nr))
  puts(" 📰📰 #{Rainbow(title_or_snippet).underline.bright}")
  #print_news_snippet(nr)
#  puts nr
  (nr['items'] or []).each do |n|
    print_news_snippet(n)
  end
end

puts("Done. Try again with some of these: #{Rainbow($sample_stocks.join(' ')).purple}")
puts("Note. It #{Rainbow('only').underline} works with NASDAQ stuff.")
