#/bin/bash

SIZE=${1:-150M}
DIR=~/iPhoto\ Library/Masters/
echo "# Find big movies in iPhoto dir ($DIR) bigger than \$1 (or $SIZE):" >&2
#echo find "$DIR" -iname '*.mov' -size $SIZE
find "$DIR" -iname '*.mov' -size +$SIZE
