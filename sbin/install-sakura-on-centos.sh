#!/bin/bash

# nothing can fail
set -e

VER=1.7
CENTOS_PKGS='vim polygen cowsay ruby ruby-devel ri rdoc irb \
 rake rubygems libxml2 libxml2-devel libxslt-devel \
 libreadline-devel openssl-devel git \
 make'
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
git clone https://github.com/palladius/sakura.git ~/git/sakura/
cd ~/git/sakura/ && make install

sudo touch /root/sakura-installed-ver$VER.touch
echo             sakura-installed-ver$VER.touch
