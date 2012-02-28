#!/bin/bash

# Usage: 
#   iphoto_big_files.sh 300M
#   iphoto_big_files.sh 300M -print0
#   iphoto_big_files.sh 300M -print0
VER=0.9

function usage() {
  echo "$0 v$VER"
  echo "Usage: $0 [-h] [--dest DESTINATIONDIR] [SIZE=150M]"
  echo -en "Sample usages: "
  echo '
   iphoto_big_files.sh -h                 # provides help
   iphoto_big_files.sh 300M               # finds files bigger than 300M
   iphoto_big_files.sh 300M -print0       #  .. and prints them in a more "xargsable" way
   iphoto_big_files.sh --dest DESTDIR     # to be implemented yet :(
More elaborate:
   iphoto_big_files.sh 400M -print0 | xargs -0 mvto /media/myhd/bigvideos/
   iphoto_big_files.sh 100M  | while read F ; do mv "$F" /Volumes/MyDisk/MyDir/; done
'
}

# cathches '-h', '--help' and much else :(
if echo "$1" | fgrep -q -- "-h" ; then
	usage
	exit 1
fi

SIZE=${1:-150M}
shift
ADDITIONAL_OPTS=$*
DIR=~/iPhoto\ Library/Masters/
echo "# Find big movies in iPhoto dir ($DIR) bigger than $SIZE (additional opts: '$ADDITIONAL_OPTS'):" >&2
#echo find "$DIR" -iname '*.mov' -size $SIZE
find "$DIR" -iname '*.mov' -size +$SIZE $ADDITIONAL_OPTS
