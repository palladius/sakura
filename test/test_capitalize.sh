
HELLO_ORIG="ciAo DA mE! proviamo qui"
# expected results
HELLO_CAPITALIZE="Ciao da me! proviamo qui"
HELLO_UP="CIAO DA ME! PROVIAMO QUI"
HELLO_DOWN="ciao da me! proviamo qui"

# According to wikipedia, capitalize of "ciao" is "Ciao", not "CIAO"!!!

CAPITALIZED="`echo "$HELLO_ORIG" | capitalize`"      # or "to_upper"
UPPED="`echo "$HELLO_ORIG" | uppercase`"    # or "to_upper"
DOWNIZED="`echo "$HELLO_ORIG" | lowercase`" # or "to_lower"

if [ "$CAPITALIZED" != "$HELLO_CAPITALIZE" ] ; then
  echo "capitalize not good: '$CAPITALIZED' <> '$HELLO_CAPITALIZE'"
  exit 41
else
  echo capitalize good
fi

if [ "$UPPED" != "$HELLO_UP" ] ; then
  echo "to_upper not good: '$UPPED' <> '$HELLO_UP'"
  exit 42
else
  echo to_upper good
fi

if [ "$DOWNIZED" != "$HELLO_DOWN" ] ; then
  echo "to_lower not good: '$DOWNIZED' <> '$HELLO_DOWN'"
  exit 43
else
  echo to_lower good
fi

echo All good.
