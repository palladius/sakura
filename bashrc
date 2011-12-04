
VER=0.9.1a
export DEBUG=true

. $SAKURADIR/bashrc.d/00-functions
. $SAKURADIR/bashrc.d/01-sakura_checks

if [ -f $SAKURADIR/bashrc.local ] ; then
	. $SAKURADIR/bashrc.local
else
   	red "Attention, bashrc.local doesnt exist. Copy it and adapt it to your situation:"
	echo " cp $SAKURADIR/bashrc.local.sample $SAKURADIR/bashrc.local"
fi

#. bashrc.d/*
. $SAKURADIR/bashrc.d/all/_common
. $SAKURADIR/bashrc.d/all/aliases
