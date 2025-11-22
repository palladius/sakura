#!/bin/bash

# nothing can fail
set -e

VER=1.7
DEBIAN_PKGS='vim polygen cowsay ruby ruby-dev ri rdoc irb rake rubygems libxml2 libxml2-dev libxslt1-dev libxslt-dev libreadline-dev libssl-dev git make'
GEMS='xmpp4r-simple xmpp4r ric bundler nokogiri google_drive rubygems-update'


# MAIN
cd
echo Trying to install $0 v$VER...
set -x
sudo apt-get install -y $DEBIAN_PKGS
sudo gem install --no-ri --no-rdoc $GEMS
sudo sudo /var/lib/gems/1.8/bin/update_rubygems

mkdir -p ~/git
git clone https://github.com/palladius/sakura.git ~/git/sakura/
cd ~/git/sakura/ && make install

sudo touch /root/sakura-installed-ver$VER.touch
echo             sakura-installed-ver$VER.touch
