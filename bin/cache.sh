#!/bin/sh

CACHEDIR=~/.riccache/
mkdir -p $CACHEDIR

cachefile=$CACHEDIR/cache

for i in "$@"
do
    cachefile=${cachefile}_$(printf %s "$i" | sed 's/./\\&/g')
done

test -f "$cachefile" || "$@" > "$cachefile"
cat "$cachefile"
