
#################
# Deploy the gem 'sakuric'

version = File.read( 'VERSION' ) rescue "0.0.42_sakbug"

Echoe.new('sakuric', version ) do |p|
  p.summary        = "My SAKURA gem. See http://github.com/palladius/sakura"
  p.description    = "My SAKURA gem with various utilities. This is my swiss-army knife for Linux and Mac. See README.md for amazing examples, like:
  
  richelp ubuntu                                   # shows a richelp of my 'ubuntu' cheatsheet
   richelp sakura synopsis                          # shows a richelp of my 'sakura' cheatsheet, grepping for 'synopsis'
   ls | act                                         # randomly scrambles the lines! Taken from cat/cat ;)
   ps | rainbow                                     # colors all lines differently
   twice itunes -                                   # lowers volume of iTunes... twice :)
   10 echo Bart Simpson likes it DRY                # tells you this 10 times. Very sarcastic script!
   seq 100 | 1suN 7                                 # prints every 7th element of the list
   zombies                                          # prints processes that show zombies (plus funny options to kill them)
   find . -size +300M | xargs mvto /tmp/bigfiles/   # moves big files to that directory
   alias gp='never_as_root git pull'                # only if u r not root it runs!
   tellme-time                                      # Tells you the time with Riccardo voice in Italian. Brilliant!
   find-duplicates .                                # Tells you files with same size/MD5 in this directory
   facter is_google_vm                              # Tells if it's a GCE Virtual Machine
  
  "
  p.url            = "http://github.com/palladius/sakura"
  p.author         = "Riccardo Carlesso"
  p.email          = "['p','ll','diusbonton].join('a') @ gmail.com"
  #  So I can't accidentally ship with without certificate! Yay!
  # See: http://rubydoc.info/gems/echoe/4.6.3/frames
  p.require_signed = true
  p.ignore_pattern = [
    "tmp/*", 
    "tmp/*", #"tmp/*/*", "tmp/*/*/*",
    "private/*",
    ".noheroku",
    '.travis.yml',
  ]
  #p.development_dependencies = [ 'ric','echoe' ]
  p.runtime_dependencies     = [ 'ric' ]
end
