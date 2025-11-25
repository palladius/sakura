#!/bin/sh

SAKURADIR=~/git/sakura


if grep -q SAKURADIR ~/.bashrc ; then
  echo Sakura already installed I guess
else
  cat templates/bashrc.inject  >> ~/.bashrc
fi

