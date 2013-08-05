#!/bin/bash

set -x

# TODO ruby-lint


#for RUBY_SCRIPT in $SAKURADIR/bin/*.rb ; do
for RUBY_SCRIPT in bin/*.rb sbin/*.rb ; do
  ruby -c $RUBY_SCRIPT || exit 1
done

exit 0
