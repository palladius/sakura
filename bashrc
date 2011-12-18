
VER=`cat "$SAKURADIR/VERSION"`
export SAKURA_VER=$VERSION

## enable/disable DEBUG
#export DEBUG=true
export DEBUG=false

if [ "nope$SAKURADIR" = "nope" ] ; then
  echo "SAKURA> Sorry, SAKURADIR is missing. Please add to ~/.bashrc something like this:" >&2
  echo "   export SAKURADIR=~/path/to/your/sakura/repo/" >&2
  echo "Or you might try the following: cat templates/bashrc.inject" >&2
fi


# TODO change to run-all or source-all :)
. $SAKURADIR/bashrc.d/00-functions
. $SAKURADIR/bashrc.d/01-sakura_checks
. $SAKURADIR/bashrc.d/all/_common
. $SAKURADIR/bashrc.d/all/aliases





