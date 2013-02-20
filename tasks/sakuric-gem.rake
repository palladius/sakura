
#################
# Deploy the gem 'sakuric'

version    = File.read( 'VERSION' )       # shouldnt rescue at all, should fail :)
cheatsheet = File.read('docz/CHEATSHEET') rescue "_COULDNT_FIND_DOCZ_CHEATSHEET"

GEM_NAMES = %w{sakuric sakura}
GEM_NAMES.each do |gemname|
  Echoe.new(gemname, version ) do |p|
    p.summary        = "My SAKURA gem. See http://github.com/palladius/sakura"
    p.description    = "My SAKURA gem with various utilities. This is my swiss-army knife for Linux and Mac. See README.md for amazing examples, like:
  
  #{cheatsheet}
    "
    p.url            = "http://github.com/palladius/sakura"
    p.author         = "Riccardo Carlesso"
    p.email          = "['p','ll','diusbonton].join('a') @ gmail.com"
    #  So I can't accidentally ship with without certificate! Yay!
    # See: http://rubydoc.info/gems/echoe/4.6.3/frames
    p.require_signed = true
    p.ignore_pattern = [
      "tmp/*", #"tmp/*/*", "tmp/*/*/*",
      "private/*",
      ".noheroku",
      '.travis.yml',
    ]
    #p.development_dependencies = [ 'ric','echoe' ]
    p.runtime_dependencies     = [ 'ric' ]
  end
end