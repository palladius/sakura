
HELLO_ORIG="Ciao da me!"
HELLO_UP="CIAO DA ME!"
HELLO_DOWN="ciao da me!"

UPPED="`echo "$HELLO_ORIG" | capitalize`"      # or "to_upper"
DOWNIZED="`echo "$HELLO_ORIG" | decapitalize`" # or "to_lower"

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
