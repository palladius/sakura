#!/bin/bash

MYKEY=${1:-__NOT_SET__}
# on Debian 7 (weezy)
curl -o /etc/apt/sources.list.d/stackdriver.list http://repo.stackdriver.com/wheezy.list &&
  curl --silent https://app.stackdriver.com/RPM-GPG-KEY-stackdriver |apt-key add - &&
  apt-get update &&
  apt-get install -y stackdriver-agent

echo Note that if you dont have the key in the isntall you can do this:
echo 'echo "stackdriver-agent stackdriver-agent/apikey string '$MYKEY'" | debconf-set-selections'
