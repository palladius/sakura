#!/bin/bash

set -x

# TODO ruby-lint:
# sudo gem install roodi
# roodi "bin/*.rb"
# roodi "sbin/*.rb"



for RUBY_SCRIPT in $SAKURADIR/*bin/*.rb ; do
  ruby -c $RUBY_SCRIPT || exit 1
done

exit 0
