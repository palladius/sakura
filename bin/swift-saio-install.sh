#!/bin/sh

# Copied from a PDF from Joshua McKenty
# "swift installation 4.McKenty.pdf"
SWIFT_IP=${1:-$( ifconfig eth0 |grep "inet addr:"|cut -f 2 -d:|cut -f 1 -d' ')}

echo This script installs Swift SAIO in your machine. You have to be root to do that.
echo "I will use the IP taken by eth0: '$SWIFT_IP'"
echo "If you dont agree, restart the script providing the IP in ARGV[1]"
echo "Is that ok? If not, pls ctrl-C"
read DOESNT_MATTER

if [ -f /root/swift-saio-already-installed.touch ] ; then
	echo "Warning, swift SAIO seems to be already installed. Quitting"
	exit 66
fi
touch /root/swift-saio-already-installed.touch

set -x
# slide 3
apt-get -y install python-software-properties
add-apt-repository ppa:swift-core/ppa
apt-get update
apt-get -y install curl gcc bzr memcached python-configobj python-coverage python-dev python-nose python-setuptools python-simplejson python-xattr sqlite3 xfsprogs python-webob python-eventlet python-greenlet python-pastedeploy python-netifaces screen vim

# slide 4
adduser swiftdemo
adduser swiftdemo admin
mkdir /srv
dd if=/dev/zero of=/srv/swift-disk bs=1024 count=0 seek=1000000
mkfs.xfs -i size=1024 /srv/swift-disk
echo "/srv/swift-disk /mnt/sdb1 xfs loop,noatime,nodiratime,nobarrier,logbufs=8 0 0" >> /etc/fstab
mkdir /mnt/sdb1
mount /mnt/sdb1
mkdir /mnt/sdb1/1 /mnt/sdb1/2 /mnt/sdb1/3 /mnt/sdb1/4
chown -R swiftdemo:swiftdemo /mnt/sdb1
for x in {1..4}; do ln -s /mnt/sdb1/$x /srv/$x; done
mkdir -p /etc/swift/object-server /etc/swift/container-server /etc/swift/account-server
mkdir -p /srv/1/node/sdb1 /srv/2/node/sdb2 /srv/3/node/sdb3 /srv/4/node/sdb4
mkdir -p /var/run/swift
chown -R swiftdemo:swiftdemo /etc/swift /mnt/sdb1 /srv/[1-4]/ /var/run/swift
sed -e "s/exit 0/mkdir \/var\/run\/swift\nchown swiftdemo:swiftdemo
\/var\/run\/swift\nexit 0/g" /etc/rc.local -i


# Step 5: rsync
# Pag 11

cat << EOF > /etc/rsyncd.conf
uid = swiftdemo
gid = swiftdemo
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
address = 127.0.0.1

# Pag 12
[account6012]
max connections = 25
path = /srv/1/node/
read only = false
lock file = /var/lock/account6012.lock
[account6022]
max connections = 25
path = /srv/2/node/
read only = false
lock file = /var/lock/account6022.lock
[account6032]
max connections = 25
path = /srv/3/node/
read only = false
lock file = /var/lock/account6032.lock
[account6042]
max connections = 25
path = /srv/4/node/
read only = false
lock file = /var/lock/account6042.lock

# Pag 13
[container6011]
max connections = 25
path = /srv/1/node/
read only = false
lock file = /var/lock/container6011.lock
[container6021]
max connections = 25
path = /srv/2/node/
read only = false
lock file = /var/lock/container6021.lock
[container6031]
max connections = 25
path = /srv/3/node/
read only = false
lock file = /var/lock/container6031.lock
[container6041]
max connections = 25
path = /srv/4/node/
read only = false
lock file = /var/lock/container6041.lock

# Pag.14
cat << EOF >> /etc/rsyncd.conf
[object6010]
max connections = 25
path = /srv/1/node/
read only = false
lock file = /var/lock/object6010.lock
[object6020]
max connections = 25
path = /srv/2/node/
read only = false
lock file = /var/lock/object6020.lock
[object6030]
max connections = 25
path = /srv/3/node/
read only = false
lock file = /var/lock/object6030.lock
[object6040]
max connections = 25
path = /srv/4/node/
read only = false
lock file = /var/lock/object6040.lock
EOF

sed -e "s/RSYNC_ENABLE=false/RSYNC_ENABLE=true/g" /etc/default/rsync -i

# Pag. 15
# Executes the following as swift
su swiftdemo -c "
mkdir ~/bin
bzr init-repo swift
cd ~/swift; bzr branch lp:swift trunk
cd ~/swift/trunk; sudo python setup.py develop
cat << EOF >> ~/.bashrc
 export SWIFT_TEST_CONFIG_FILE=/etc/swift/func_test.conf
 export PATH=${PATH}:~/bin
EOF
. ~/.bashrc
"

# Pag 16
cd /etc/swift
openssl req -new -x509 -nodes -out cert.crt -keyout cert.key
# USE IP for COMMON NAME









################################################################################
# End of everything
touch /root/swift-saio-already-installed.touch
