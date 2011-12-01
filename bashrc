

# TODO: verify that $SAKURADIR is set otherwise exit saying:
# Sorry, inject 'bashrc.inject' THIS into .bashrc
export SAKURA=true
export SAKURADIR=~/git/sakura
export SAKURABIN=$SAKURADIR/bin
export SAKURASBIN=$SAKURADIR/sbin
export SAKURALIB=$SAKURADIR/lib

alias 'cdsak=cd $SAKURADIR'
export PATH=$PATH:$SAKURABIN
alias sak="giallo With sakura everything is easier and more verbose..; . $SAKURADIR/.bashrc"
