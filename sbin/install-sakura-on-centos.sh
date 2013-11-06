#!/bin/bash

# nothing can fail
set -e

VER=1.6
CENTOS_PKGS='vim polygen cowsay ruby1.8-dev ruby1.8 ri1.8 rdoc1.8 irb1.8 \
 rake rubygems libxml2 libxml2-dev libxslt1-dev \
 libxslt-dev libxml2-dev libreadline-ruby1.8 libruby1.8 libopenssl-ruby git \
 googlecl make'
GEMS='xmpp4r-simple xmpp4r ric bundler nokogiri google_drive rubygems-update'

echo Please read out/err in here: .install.*
exec 1>.install.log 2>.install.err

# MAIN
cd
echo Trying to install $0 v$VER...
set -x
# this part works, tested on CentOS!
sudo yum install -y $CENTOS_PKGS
sudo gem install --no-ri --no-rdoc $GEMS

# doesnt work on CentOS
# on debian
#sudo sudo /var/lib/gems/1.8/bin/update_rubygems
/usr/bin/update_rubygems
sudo gem update --system &

mkdir -p ~/git
git clone git://github.com/palladius/sakura.git ~/git/sakura/
cd ~/git/sakura/ && make install

sudo touch /root/sakura-installed-ver$VER.touch
echo             sakura-installed-ver$VER.touch
