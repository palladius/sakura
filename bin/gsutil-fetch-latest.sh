#!/bin/bash

# run this as normal user, with bash shell
# Author: aiurlano

GZNAME='gsutil.tar.gz'
GCURL='http://storage.googleapis.com/pub/'${GZNAME}
#echo ${GCURL}
#echo ${GZNAME}

sudo rm -fr /usr/local/gsutil
cd /usr/local/

sudo -E wget -c ${GCURL} -O ${GZNAME}

sudo tar zxvf ${GZNAME}

export FOLDERNAME=${GZNAME:0:$((${#GZNAME}-7))}


#check if it was added to the path
grep -q '/usr/local/gsutil' ~/.bashrc
if [ $? -ne 0 ]; then
  cat <<EOF >> ~/.bashrc

export PATH=\${PATH}:/usr/local/gsutil

EOF
  echo "Warning: Your .bashrc file was modified."
  echo "         Remember to do . ~/.bashrc or logout and log back in"
fi
