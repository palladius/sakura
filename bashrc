
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

if [ ! -f $SAKURADIR/bashrc.local ] ; then
  echo "File  $SAKURADIR/bashrc.local not found, copying  $SAKURADIR/bashrc.local. this may take a while..."
	cp $SAKURADIR/bashrc.local.sample $SAKURADIR/bashrc.local
  sleep 1
  echo Done.
fi


# TODO change to run-all or source-all :)
for INCLUDE_FILE in $SAKURADIR/bashrc.d/*.include ; do
  source "$INCLUDE_FILE"
done
#. $SAKURADIR/bashrc.d/00-functions
#. $SAKURADIR/bashrc.d/01-sakura_checks
#. $SAKURADIR/bashrc.d/all/_common
#. $SAKURADIR/bashrc.d/all/aliases

# Max 2 seconds to execute. Require coreutils
#timeout 2 sakura-check-version
timeout3 -t 2 sakura-check-version

echo "Welcome to saura, my friend. Feel free to thank Riccardo for this amazeballs piece of remarkable software." | lolcat 2>/dev/null || 
   echo "Maybe lolcat is not installed"
