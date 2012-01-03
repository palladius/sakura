#/bin/bash


# Usage: 
#   iphoto_big_files.sh 300M
#   iphoto_big_files.sh 300M -print0

SIZE=${1:-150M}
shift
ADDITIONAL_OPTS=$*
DIR=~/iPhoto\ Library/Masters/
echo "# Find big movies in iPhoto dir ($DIR) bigger than $SIZE (additional opts: '$ADDITIONAL_OPTS'):" >&2
#echo find "$DIR" -iname '*.mov' -size $SIZE
find "$DIR" -iname '*.mov' -size +$SIZE $ADDITIONAL_OPTS
