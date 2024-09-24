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

$default_search_key = 'Civitavecchia'
$prog_version = '1.1'
SEARCH_KEY = ARGV[0] || $default_search_key
puts("🔧 Checking News about: #{Rainbow(SEARCH_KEY).purple}")

params = {
  api_key: SERP_API_KEY,
  engine: "google_news",
  hl: "en", # forse posso omettere..
#  q: "#{$stock_to_check}:NASDAQ",
  q: SEARCH_KEY,
}


def cached_google_search(params, version=$prog_version)
  cache_key = Digest::MD5.hexdigest(params.to_s + $prog_version) # so it changes cache if you bump up version
  cache_file = ".cache/serp.news.#{cache_key}.json"

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

# Keys position, title, source, link, thumbnail, date
def print_fancy_news_line(x)
    return if x.nil?
    is_inutile = (x.fetch('date', nil) and x.fetch('title', nil)).nil?
    return if is_inutile
    # Gets YYYYMMDD
    if x.fetch('date', nil)
      timestampy_horrible_date = x.fetch 'date' #, '??' # 09/16/2024, 07:00 AM, +0000 UTC
      date_part = timestampy_horrible_date.split(',')[0]
      #puts(date_part)
      fancy_date = Date.strptime(date_part, '%m/%d/%Y')
    else
      fancy_date = 'BOH'
    end
    # Title and position
    colored_title = Rainbow(x.fetch 'title').white.bold
    posish = x.fetch 'position'

    source = x.dig('source', 'name')
    link = x.dig('link') # , 'name')

    # Assembling all
    news = "📰 #{Rainbow(posish).cyan} #{fancy_date} #{colored_title} (#{source}) 🌍 #{Rainbow(link).blue.underline}"
    puts news
    news
  end

# def print_fancy_stock_line(x)
#   return if x.nil?
#   stock_name = x['name'] || x['stock']
#   currency = x.fetch 'currency', '💲'
#   mov_hash =x['price_movement']
#   price_02 = x['price'].round(2) rescue x['price']
#   sign =  mov_hash['movement'] == 'Up' ? '+' : '-'
# #  movement_val = mov_hash['percentage'].to_s.format('%02d', 4) rescue 4242
#   movement_val = "#{sign}#{mov_hash['percentage'].round(2)}%" # .to_s.format('%02d', 4) rescue 4242
#   colored_movement = Rainbow(movement_val).send(mov_hash['movement'] == 'Up' ? :green : :red)
#   puts "📈 #{stock_name}:\t #{price_02}#{currency}\t#{colored_movement}"
# end

def print_news_snippet(n)
  if n['snippet']
    puts(" 🗞️  #{Rainbow(n['snippet']).yellow} (#{n['source']}, #{n['date']})")
  #else
    #puts("🐞🐞🐞 #{n}")
  end
end



search = cached_google_search(params)
hash_results = search # .get_hash rescue search
puts hash_results if $DEBUG
#puts hash_results.keys

puts("1. News:")

if hash_results.dig('error')
  puts Rainbow(hash_results.dig('error')).red
else
  hash_results['news_results'].each_with_index do |obj,ix|
    break if ix >= 10
    print_fancy_news_line(obj)
    #print_fancy_stock_line(x)
  end if hash_results['news_results']
end
# #binding.pry

# hash_results['news_results']['us'].each do |x|
#   print_fancy_stock_line(x)
# end

# if $DEBUG
#   puts("🐞 hash_results.keys: #{hash_results.keys.join ' '}")
#   puts("🐞 hash_results.market.keys: #{hash_results['markets'].keys.join ' '}")
# end
# puts("2. Your stock info SUMMARY:")
# puts hash_results['summary'] if $DEBUG
# print_fancy_stock_line(hash_results['summary'])

# puts("3. Market TopNews:")
# n = hash_results['markets']['top_news']
# print_news_snippet(n)

# news_results = hash_results['news_results']
# puts("4. News Results:")
# (hash_results['news_results'] or []).each do |nr|
#   title_or_snippet = nr.fetch('title', nr.fetch('snippet', nr))
#   puts(" 📰📰 #{Rainbow(title_or_snippet).underline.bright}")
#   (nr['items'] or []).each do |n|
#     print_news_snippet(n)
#   end
# end

# puts("Done. Try again with some of these: #{Rainbow($sample_stocks.join(' ')).purple}")
# puts("Note. It #{Rainbow('only').underline} works with NASDAQ stuff.")
