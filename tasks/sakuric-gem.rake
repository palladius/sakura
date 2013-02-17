
#################
# Deploy the gem 'sakuric'
Echoe.new('sakuric', version ) do |p|
  p.description    = "My SAKURA gem with various utilities. This is my swiss-army knife for Linux and Mac. See README.md for amazing examples"
  p.url            = "http://github.com/palladius/sakura"
  p.author         = "Riccardo Carlesso"
  p.email          = "['p','ll','diusbonton].join('a') @ gmail.com"
  p.ignore_pattern = [
    "tmp/*", 
    "tmp/*", #"tmp/*/*", "tmp/*/*/*",
    "private/*",
    ".noheroku",
    '.travis.yml',
  ]
  p.development_dependencies = [ 'ric','echoe' ]
  p.runtime_dependencies     = [ 'ric' ]
end
