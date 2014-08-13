#!/bin/bash

STACKDRIVER_API_KEY=${1:-_NOT_SET_}

# on CentOS or RedHat
echo "Your STACKDRIVER_API_KEY is '$STACKDRIVER_API_KEY'. If its empty please CTRL-C and export it to real value or give it as ARGV[1]" &&
curl -o /etc/yum.repos.d/stackdriver.repo http://repo.stackdriver.com/stackdriver-el6.repo &&
  yum install stackdriver-agent &&
  /opt/stackdriver/stack-config --api-key "$STACKDRIVER_API_KEY"
