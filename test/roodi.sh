#!/bin/bash

# Requires:
#   sudo gem install roodi
# PS. Dependency is in Gemfile

echo pwd: $(pwd)

roodi "./bin/*.rb"
roodi "./sbin/*.rb"
