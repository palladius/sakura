#!/bin/bash

#URL: http://redis.io/download

wget http://redis.googlecode.com/files/redis-2.6.9.tar.gz
tar xzf redis-2.6.9.tar.gz
cd redis-2.6.9
make

# start server
src/redis-server &

echo 'set foo riccardobar' | rc/redis-cli
echo  get foo| rc/redis-cli > /root/redis-get-foo.out
