#!/bin/sh

SAKURADIR=~/git/sakura

gem install echoe

if grep -q SAKURADIR ~/.bashrc ; then
  echo Sakura already installed I guess
else
  cat templates/bashrc.inject  >> ~/.bashrc
fi

