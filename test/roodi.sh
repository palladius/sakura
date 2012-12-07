#!/bin/bash

# Requires:
#   sudo gem install roodi
# PS. Dependency is in Gemfile

roodi "bin/*.rb"
roodi "sbin/*.rb"
