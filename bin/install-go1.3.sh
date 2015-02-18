#! /bin/bash
 
# This file creates a couple of scripts..
VER=1.6
 
# if grep GOROOT ~/.bashr TODO
 
echo '# adding vars to bashrc. Make sure to execute this only once
export GOROOT=/opt/go
export PATH=$PATH:$GOROOT/bin' \
>> ~/.bashrc
 
cat > install-gov1.3.sh <<EOF
#! /bin/bash
#set -x
 
VER=$VER # inherits from father :)
 
set -e
 
mkdir -p /opt
cd /opt
wget https://storage.googleapis.com/golang/go1.3.3.linux-amd64.tar.gz
tar -zxvf go1.3.3.linux-amd64.tar.gz
 
cat >/opt/hello.go << EOFBIS
 package main
 import "fmt"
 func main() {
    fmt.Printf("hello, world. Go seems to work fine!\n")
 }
EOFBIS
EOF
 
echo "- To run, launch:      source ~/.bashrc && sudo sh install-gov1.3.sh "
echo "- To test:             go run /opt/hello.go"
