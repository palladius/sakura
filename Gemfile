# Scopiazzed from Gruff gem
# Messo ruby 2.5.3. Speriamo!

# pre install Linux: simile

source 'https://rubygems.org'

gem 'dotenv' # to use kubernetes-service
#gem 'echoe'
gem 'facter'
gem 'ric'
gem 'google-cloud-logging'
gem 'lolcat'
gem 'filecache'
#gem 'sakuric'


group :pinger do
  # Just for pinger...
  gem 'net-ping'
  gem 'net-http'
  gem 'uri'
end

#gem 'psych'

group :test do
  gem 'rake'
  # For linting
  gem 'roodi'
  gem 'nitpick'

  platform :ruby do
    # requires in Ubuntu: sudo apt-get install libmagick++-dev
    # requires for Mac:    brew install pkg-config imagemagick
    #gem 'rmagick'
  end

#  platform :jruby do
#    gem 'rmagick4j'
#  end
end

