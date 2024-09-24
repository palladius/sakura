#!/usr/bin/env ruby

# Ricc figata! copiato da SERP.com
#  https://serpapi.com/playground?engine=google_flights&departure_id=ZRH&arrival_id=AMS&hl=it&currency=CHF&outbound_date=2024-01-01&return_date=2024-01-05&adults=2&stops=1
require 'google_search_results'
require 'rainbow'
require 'digest'
require 'yaml'
require 'pry'
require 'byebug'

$prog_version = '1.0'
MAX_ITEMS = 10
SERP_API_KEY = ENV.fetch 'SERP_API_KEY', nil
raise('Missing ENV["SERP_API_KEY"].. failing.') unless SERP_API_KEY
def parse_location(args, dflt)
  location = args[0..].join(" ")
  return dflt if location == ''
  return location
end
$multi_map = []

# $default_search_key = 'Bali Resorts'
# SEARCH_KEY = ARGV[0] || $default_search_key
SEARCH_KEY = parse_location(ARGV, 'Bali Resorts')
tomorrow = (Date.today + 1).to_s
post_tomorrow = (Date.today + 2).to_s
one_week_after = (Date.today + 8).to_s
puts("🔧 Checking News about: #{Rainbow(SEARCH_KEY).purple} for #{tomorrow} to #{one_week_after}")

params = {
  api_key: SERP_API_KEY,
  engine: "google_hotels",
  q: SEARCH_KEY,
  hl: "en",
  gl: "us",
  check_in_date: tomorrow, # "2024-09-23", # tomorrow
  check_out_date: one_week_after, # "2024-09-24", # aftertomorrow
  currency: "USD"
}
# params = {
#   api_key: "YOUR_SERP_API_KEY",
#   engine: "google_news",
#   hl: "en", # forse posso omettere..
# #  q: "#{$stock_to_check}:NASDAQ",
#   q: SEARCH_KEY,
# }


def cached_google_search(params, version=$prog_version)
  cache_key = Digest::MD5.hexdigest(params.to_s + $prog_version) # so it changes cache if you bump up version
  cache_file = ".cache/serp.news.#{cache_key}.json"

  if File.exist?(cache_file)
    puts  Rainbow("[debug] Cache hit: #{cache_file}").green
    puts(File.read(cache_file))
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
# input:
# {"latitude"=>44.47016906738281, "longitude"=>11.884200096130371}
# {"latitude"=>44.7479131, "longitude"=>11.8307671}
# {"latitude"=>44.7270405, "longitude"=>11.8825802}
# {"latitude"=>44.750403899999995, "longitude"=>11.9494893}
# {"latitude"=>44.47016906738281, "longitude"=>11.884200096130371}
def get_multimarker_map_yandex(aom)
  # https://stackoverflow.com/questions/35400664/google-maps-multiple-markers-via-url-only
  #sample_map = 'https://yandex.ru/maps/?ll=30.310182,59.951059&pt=30.335429,59.944869~30.34127,59.89173&z=12&l=map'
  baricentrum = "#{aom[0]['longitude']},#{aom[0]['latitude']}"
  final_url = "https://yandex.ru/maps/?ll=#{baricentrum}&pt="
 # final_url = "https://yandex.ru/maps/?pt="
  inframmezzo = aom.map do |point|
    lat = point['latitude'].round(6)
    long = point['longitude'].round(6)
    #puts " 🐞  #{lat}    ---    #{long}"
    "#{long},#{lat}" # dont ask me why they reverse it
  end
  final_url << inframmezzo.join('~')
  #puts aom.class
  final_url << '&z=15&l=map'
  final_url
end

def get_multimarker_map_google(aom)
  # https://stackoverflow.com/questions/35400664/google-maps-multiple-markers-via-url-only
  # sample: https://www.google.com/maps/dir/33.93729,-106.85761/33.91629,-106.866761/33.98729,-106.85861//@34.0593359,-106.7131944,11z
  final_url = "https://www.google.com/maps/dir/"
  inframmezzo = aom.map do |point|
    lat = point['latitude'].round(6)
    long = point['longitude'].round(6)
    #puts " 🐞  #{lat}    ---    #{long}"
    "#{lat},#{long}" # dont ask me why they reverse it
  end
  final_url << inframmezzo.join('/')
  #puts aom.class
  final_url << "//@#{inframmezzo[0]},11z" # TODO add @ primo punto
  final_url
end

# # Keys position, title, source, link, thumbnail, date
# def print_fancy_news_line(x)
#     return if x.nil?
#     is_inutile = (x.fetch('date', nil) and x.fetch('title', nil)).nil?
#     return if is_inutile
#     # Gets YYYYMMDD
#     if x.fetch('date', nil)
#       timestampy_horrible_date = x.fetch 'date' #, '??' # 09/16/2024, 07:00 AM, +0000 UTC
#       date_part = timestampy_horrible_date.split(',')[0]
#       #puts(date_part)
#       fancy_date = Date.strptime(date_part, '%m/%d/%Y')
#     else
#       fancy_date = 'BOH'
#     end
#     # Title and position
#     colored_title = Rainbow(x.fetch 'title').white.bold
#     posish = x.fetch 'position'

#     source = x.dig('source', 'name')
#     link = x.dig('link') # , 'name')

#     # Assembling all
#     news = "📰 #{Rainbow(posish).cyan} #{fancy_date} #{colored_title} (#{source}) 🌍 #{Rainbow(link).blue.underline}"
#     puts news
#     news
#   end
def print_fancy_hotel_line(x)
  return if x.nil?
#  puts(x.keys.join ',')
  id = x.dig 'id'
  hotel_name = Rainbow(x.dig 'name').bold
  children = x.dig('children').map{|c| c['name']}.join ', ' rescue nil # .join(', ') #rescue nil
  children_addon = children ? " (#{Rainbow(children).purple.italic})" : ''
#  puts x
  hotel_line = " 🏩 #{hotel_name}#{children_addon}"
  puts hotel_line
  hotel_line
end

def star_rating_to_emojis(rating)
  emojis = ['⭐', '⭐️⭐️', '⭐️⭐️⭐️', '⭐️⭐️⭐️⭐️', '⭐️⭐️⭐️⭐️⭐️']
  emojis[rating - 1] # rescue '?' # || 'No rating'
end
def parse_rating(hotel_class)
  match = hotel_class.to_s.match(/(\d+)-star hotel/)
  return match[1].to_i if match
  return nil
end
def class_stars(hotel_class)
  #puts("DEB hotel_class=#{hotel_class}")
  star_rating_to_emojis(parse_rating(hotel_class)) rescue hotel_class
end

def colorize_by_rating(one_to_five)
  return :green if one_to_five >= 4 rescue :darkgray
  :red
end
def emoji_by_transporation_type(transporation_type:)
   # Taxi, Waling
   return '🚕' if transporation_type == 'Taxi'
   return '🚶‍♂️‍➡️' if transporation_type == 'Walking'
   raise Error("Unkonwn transportation: #{transporation_type}")
end
def render_nearby_place(nb)
  transportation = nb['transportations'].first
  transportation_emoji = emoji_by_transporation_type( transporation_type: transportation['type'])

  nb_str = "#{nb.dig 'name'} (#{transportation_emoji} #{transportation['duration']})"

end

def google_maps_link_by_coordinates(x)
  lat = x.dig 'latitude'
  long = x.dig 'longitude'
  $multi_map << x
  z = 15
  "https://www.google.com/maps/@#{lat},#{long},#{z}z"
#  raise 42
end

# Keys:
#  type,name,description,link,gps_coordinates,check_in_time,check_out_time,rate_per_night,
#  total_rate,nearby_places,hotel_class,extracted_hotel_class,images,overall_rating,reviews,ratings
#  location_rating,reviews_breakdown,amenities,property_token,serpapi_property_details_link
def print_fancy_property_line(x, verbose: true)
  return if x.nil?
#  puts(x.keys.join ',')
  is_inutile = (x.fetch('rate_per_night', nil)).nil? #  and x.fetch('title', nil)
  return if is_inutile
  id = x.dig 'id'
  name = Rainbow(x.dig 'name').bold
  hotel_type = Rainbow(x.dig 'type').bold
  description = Rainbow(x.dig 'description').italic.cyan
  description_str = x.dig('description')? ", #{description}" : ''
  #children = x.dig('children').map{|c| c['name']}.join ', ' rescue nil # .join(', ') #rescue nil
  #children_addon = children ? " (#{Rainbow(children).purple.italic})" : ''
  price_str = x.dig('rate_per_night', 'lowest') + '/💤'
  # if price_str == '' or price_str.to_s == ''
  #   puts("ERROR: #{x.keys}")
  #   puts("ERROR: #{x.dig('rate_per_night')}")
  # end
  colored_rating  = Rainbow(x.dig('overall_rating').round(1)).yellow rescue Rainbow('-').darkred # x.dig('overall_rating')
#  url = x.dig('serpapi_property_details_link')
  url = x.dig('link')
  emoji_stars_addon = x.dig('hotel_class')  ? class_stars( x.dig('hotel_class')) + ' ' : ''

#  puts x
  hotel_line = " 🏨 #{Rainbow(price_str).green.bold} #{colored_rating}✨ #{name} #{emoji_stars_addon}(#{Rainbow(hotel_type).yellow}#{description_str}) 🌍 #{Rainbow(url).blue.underline.faint}"
  if verbose
    reviews_breakdown = x.dig('reviews_breakdown') or []
    #print(reviews_breakdown)
    #Dovrebbe essere []. not NIL
    #binding.pry if reviews_breakdown.nil?
    #Reviews: [{"name"=>"Service", "description"=>"Service", "total_mentioned"=>219, "positive"=>145, "negative"=>64, "neutral"=>10}, {"name"=>"Breakfast", "description"=>"Breakfast", "total_mentioned"=>102, "positive"=>64, "negative"=>28, "neutral"=>10}, {"name"=>"Location", "description"=>"Location", "total_mentioned"=>53, "positive"=>31, "negative"=>11, "neutral"=>11}, {"name"=>"Gym", "description"=>"Gym", "total_mentioned"=>10, "positive"=>3, "negative"=>7, "neutral"=>0}, {"name"=>"Safety", "description"=>"Safety", "total_mentioned"=>17, "positive"=>4, "negative"=>13, "neutral"=>0}, {"name"=>"Air Conditioning", "description"=>"Air conditioning", "total_mentioned"=>18, "positive"=>2, "negative"=>14, "neutral"=>2}]
    reviews_breakdown_arr = reviews_breakdown.nil? ? [] : reviews_breakdown.map{|rh|
      name = rh['name']
      positives = rh['positive'] # .class
      negatives = rh['negative']
      final_verdict_color = positives > negatives ? :green : :red
      colored_name = Rainbow(name).send(final_verdict_color)
      colored_review = "#{colored_name} +#{positives}/-#{negatives}"
      colored_review
    }
    hotel_line += "\n    🔎 Reviews: #{reviews_breakdown_arr.join(', ')}" if reviews_breakdown_arr.size > 0
#    hotel_line += "\n    🌟 Stars: #{class_stars x.dig('hotel_class')}" if x.dig('hotel_class')
    hotel_line += "\n    🔑 Keys: #{x.keys}" if $DEBUG
#    hotel_line += "\n    🌍 URL: #{x.dig 'link'}" if x.dig 'link'
    gmap = google_maps_link_by_coordinates(x.dig 'gps_coordinates')
    hotel_line += "\n    🌍 Locay: #{gmap}" # if x.dig 'gps_coordinates'
    location_rating = x.dig 'location_rating'
    col_rating  = Rainbow(location_rating).send(colorize_by_rating(location_rating))
      hotel_line += " 🌟 Rating: #{col_rating}" # if x.dig 'location_rating'
    hotel_line += "\n    🌍 Eco-certified: #{x.dig 'eco_certified'}" if x.dig 'eco_certified'
    amenities = x.dig('amenities').join(', ')
    hotel_line += "\n    🌟 Amenities: #{Rainbow(amenities).green}" # if x.dig 'location_rating'
   # hotel_line += "\n    ✍🏿 #reviews: #{x.dig('reviews')}" # if x.dig 'location_rating'
    hotel_line += "\n    💁 essential_info: #{x.dig('essential_info')}" if x.dig 'essential_info'
    nearby_places = x.dig 'nearby_places'
    nearby_places_arr = nearby_places.map{|nb| render_nearby_place(nb)} rescue nil
    hotel_line += "\n    🗺️  nearby_places: #{nearby_places_arr}"  if nearby_places_arr


  end
  puts hotel_line
  hotel_line
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

# def print_news_snippet(n)
#   if n['snippet']
#     puts(" 🗞️  #{Rainbow(n['snippet']).yellow} (#{n['source']}, #{n['date']})")
#   #else
#     #puts("🐞🐞🐞 #{n}")
#   end
# end



search = cached_google_search(params)
hash_results = search # .get_hash rescue search
puts hash_results if $DEBUG
#puts hash_results.keys

puts("1. Brands:")

if hash_results.dig('error')
  puts Rainbow(hash_results.dig('error')).red
else
  hash_results['brands'].each_with_index do |obj,ix|
    break if ix >= 10
    print_fancy_hotel_line(obj)
    #print_fancy_stock_line(x)
  end if hash_results['brands']
end
# #binding.pry

# hash_results['news_results']['us'].each do |x|
#   print_fancy_stock_line(x)
# end

# if $DEBUG
#   puts("🐞 hash_results.keys: #{hash_results.keys.join ' '}")
#   puts("🐞 hash_results.market.keys: #{hash_results['markets'].keys.join ' '}")
# end
puts("2. Properties")
puts hash_results['properties'] if $DEBUG
# print_fancy_stock_line(hash_results['summary'])
(hash_results['properties'] or []).each_with_index do |x,ix|
  break if ix >= MAX_ITEMS
#  puts(x)
  #print_fancy_hotel_line(x)
  print_fancy_property_line(x) # rescue nil
end
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
yandex_url = get_multimarker_map_yandex($multi_map)
google_url = get_multimarker_map_google($multi_map)
puts("🗺️ 3. See all hotels on the map here:")
puts("  🇷🇺  Yandex: #{yandex_url}")
puts("  🇺🇸  Google: #{google_url}")
