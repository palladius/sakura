
echo sourceing bashrc on Sakura: DEBUG
#set -x
# TODO: verify that $SAKURADIR is set otherwise exit saying:
# Sorry, inject 'bashrc.inject' THIS into .bashrc
# This should be changed by the user
export SAKURA_BASHRC_PARSED=true

. bashrc.d/*
