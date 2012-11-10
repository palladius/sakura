#!/bin/bash

# Usage: 
#   iphoto_big_files.sh 300M
#   iphoto_big_files.sh 300M -print0
#   iphoto_big_files.sh 300M -print0
VER=0.9
SIZE=${1:-150M}
shift
ADDITIONAL_OPTS=$*
DIR=~/iPhoto\ Library/Masters/

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
   iphoto_big_files.sh 100M  | while read F ; do mv -n "$F" /Volumes/MyDisk/MyDir/; done # moves without overwriting
'
}
#iphoto_big_files.sh 60M | while read t ; do mv -n "$t" /Volumes/FreeAgent\ GoFlex\ Drive/important-backups/; done

# cathches '-h', '--help' and much else :(
if echo "$SIZE" | fgrep -q -- "-h" ; then
	usage
	exit 1
fi

echo "# Find big movies in iPhoto dir ($DIR) bigger than $SIZE (additional opts: '$ADDITIONAL_OPTS'):" >&2
#echo find "$DIR" -iname '*.mov' -size $SIZE
find "$DIR" -iname '*.mov' -size +$SIZE $ADDITIONAL_OPTS
