
# on Debian 7 (weezy)
curl -o /etc/apt/sources.list.d/stackdriver.list http://repo.stackdriver.com/wheezy.list &&
  curl --silent https://app.stackdriver.com/RPM-GPG-KEY-stackdriver |apt-key add - &&
  apt-get update &&
  apt-get install -y stackdriver-agent 

