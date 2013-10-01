#!/bin/sh

# This AMAZING script "pings" a HTTP resource via curl. Returns "." if 200,
# returns "!" elsewhere (note that 302 are treated like 404 so far... its a
# simple script!).

F=${1:-_GIVE_ME_THE_FILE_}
OUT=log-$(data)-from-$F.out
VERBOSE=true

rm $OUT 2>/dev/null

usage() {
  echo "Usage: $0 <FILENAME>"
  echo
  echo "Example:"
  echo " echo http://www.palladius.it/ >> t"
  echo " echo http://www.palladius.it/joomla/ >> t"
  echo " $0 t"
  exit 1
}
curl_http_code() {
   curl -I "$1"|head -1 |awk '{print $2}'
}

if [ ! -f "$F" ]; then
  echo "File '$F' not found :/" >&2
  usage
fi

echo "Scavenging urls from file $F:"
echo "Logging to: $OUT"
echo "-------------------------------------------------------"

# enters eternal loop
PASS=0
while true ; do
  PASS=$(( $PASS + 1 ))
  echo -en "[Pass $PASS] "
  cat "$F" |
    while read i ; do
      HTTP_CODE="$( curl_http_code "$i" 2>/dev/null )"
      # curl error, note that it returns 0 also on 404s...
      ERR=$?
      if $VERBOSE; then
        echo -en "$HTTP_CODE "
      else
        if [ "200" = "$HTTP_CODE" ]; then
          echo -en '.'
        else
          echo -en '!'
        fi
      fi
      echo "$(date) - $ERR - $HTTP_CODE - $i" >> $OUT
    done
    echo
    sleep 1
done
