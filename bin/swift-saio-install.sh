#!/bin/sh

# Copied from a PDF from Joshua McKenty
# "swift installation 4.McKenty.pdf"
export SWIFT_IP=${1:-$( ifconfig eth0 |grep "inet addr:"|cut -f 2 -d:|cut -f 1 -d' ')}

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

# Pag 17
cat << EOF >> /etc/swift/proxy-server.conf
[DEFAULT]
bind_port = 443
bind_ip = $SWIFT_IP
cert_file = /etc/swift/cert.crt
key_file = /etc/swift/cert.key
user = swiftdemo
log_facility = LOG_LOCAL1

[pipeline:main]
pipeline = healthcheck cache swauth proxy-server

[app:proxy-server]
use = egg:swift#proxy
allow_account_management = true

[filter:swauth]
use = egg:swift#swauth
super_admin_key = swauthkey
default_swift_cluster = local#https://$SWIFT_IP:443/v1

[filter:healthcheck]
use = egg:swift#healthcheck

[filter:cache]
use = egg:swift#memcache
EOF

# Pag 18
cat << EOF >> /etc/swift/swift.conf
[swift-hash]
# random unique string that can never change
swift_hash_path_suffix = riccardo-sakura-swift-tutorial
EOF

# Pag 19: Account server
cd /etc/swift/account-server
cat << EOF > 1.conf
[DEFAULT]
devices = /srv/1/node
mount_check = false
bind_port = 6012
user = swiftdemo
log_facility = LOG_LOCAL2
[pipeline:main]
pipeline = account-server
[app:account-server]
use = egg:swift#account
[account-replicator]
vm_test_mode = yes
[account-auditor]
[account-reaper]
EOF
sed -e "s/srv\/1/srv\/2/" -e "s/6012/6022/" -e "s/LOG_LOCAL2/LOG_LOCAL3/" 1.conf > 2.conf
sed -e "s/srv\/1/srv\/3/" -e "s/6012/6032/" -e "s/LOG_LOCAL2/LOG_LOCAL4/" 1.conf > 3.conf
sed -e "s/srv\/1/srv\/4/" -e "s/6012/6042/" -e "s/LOG_LOCAL2/LOG_LOCAL5/" 1.conf > 4.conf

# Pag 20: Container
cd /etc/swift/container-server
cat << EOF > 1.conf
[DEFAULT]
devices = /srv/1/node
mount_check = false
bind_port = 6011
user = swiftdemo
log_facility = LOG_LOCAL2
[pipeline:main]
pipeline = container-server
[app:container-server]
use = egg:swift#container
[container-replicator]
vm_test_mode = yes
[container-updater]
[container-auditor]
EOF
sed -e "s/srv\/1/srv\/2/" -e "s/601/602/" -e "s/LOG_LOCAL2/LOG_LOCAL3/" 1.conf > 2.conf
sed -e "s/srv\/1/srv\/3/" -e "s/601/603/" -e "s/LOG_LOCAL2/LOG_LOCAL4/" 1.conf > 3.conf
sed -e "s/srv\/1/srv\/4/" -e "s/601/604/" -e "s/LOG_LOCAL2/LOG_LOCAL5/" 1.conf > 4.conf

# Pag 21: Object Server
cd /etc/swift/object-server
cat << EOF > 1.conf
[DEFAULT]
devices = /srv/1/node
mount_check = false
bind_port = 6010
user = swiftdemo
log_facility = LOG_LOCAL2
[pipeline:main]
pipeline = object-server
[app:object-server]
use = egg:swift#object
[object-replicator]
vm_test_mode = yes
[object-updater]
[object-auditor]
EOF
sed -e "s/srv\/1/srv\/2/" -e "s/601/602/" -e "s/LOG_LOCAL2/LOG_LOCAL3/" 1.conf > 2.conf
sed -e "s/srv\/1/srv\/3/" -e "s/601/603/" -e "s/LOG_LOCAL2/LOG_LOCAL4/" 1.conf > 3.conf
sed -e "s/srv\/1/srv\/4/" -e "s/601/604/" -e "s/LOG_LOCAL2/LOG_LOCAL5/" 1.conf > 4.conf

# Pag 22: Binaries
su swiftdemo -c "
cat << EOF > ~/bin/resetswift
#!/bin/bash

swift-init all stop
# find /var/log/swift -type f -exec rm -f {} \;
sudo umount /mnt/sdb1
sudo mkfs.xfs -f -i size=1024 /srv/swift-disk
sudo mount /mnt/sdb1
sudo mkdir /mnt/sdb1/1 /mnt/sdb1/2 /mnt/sdb1/3 /mnt/sdb1/4
sudo chown swiftdemo:swiftdemo /mnt/sdb1/*
mkdir -p /srv/1/node/sdb1 /srv/2/node/sdb2 /srv/3/node/sdb3 /srv/4/node/sdb4
sudo chown swiftdemo:swiftdemo /mnt/sdb1/*
sudo rm -f /var/log/debug /var/log/messages /var/log/rsyncd.log /var/log/syslog
sudo service rsyslog restart
sudo service memcached restart
EOF

# Pag 23: Binaries 2
cat << EOF > ~/bin/remakerings
#!/bin/bash

cd /etc/swift

rm -f *.builder *.ring.gz backups/*.builder backups/*.ring.gz

swift-ring-builder object.builder create 18 3 1
swift-ring-builder object.builder add z1-$SWIFT_IP:6010/sdb1 1
swift-ring-builder object.builder add z2-$SWIFT_IP:6020/sdb2 1
swift-ring-builder object.builder add z3-$SWIFT_IP:6030/sdb3 1
swift-ring-builder object.builder add z4-$SWIFT_IP:6040/sdb4 1
swift-ring-builder object.builder rebalance
swift-ring-builder container.builder create 18 3 1
swift-ring-builder container.builder add z1-$SWIFT_IP:6011/sdb1 1
swift-ring-builder container.builder add z2-$SWIFT_IP:6021/sdb2 1
swift-ring-builder container.builder add z3-$SWIFT_IP:6031/sdb3 1
swift-ring-builder container.builder add z4-$SWIFT_IP:6041/sdb4 1
swift-ring-builder container.builder rebalance
swift-ring-builder account.builder create 18 3 1
swift-ring-builder account.builder add z1-$SWIFT_IP:6012/sdb1 1
swift-ring-builder account.builder add z2-$SWIFT_IP:6022/sdb2 1
swift-ring-builder account.builder add z3-$SWIFT_IP:6032/sdb3 1
swift-ring-builder account.builder add z4-$SWIFT_IP:6042/sdb4 1
swift-ring-builder account.builder rebalance
EOF

# Pag 24:
cat << EOF > ~/bin/startmain
#!/bin/bash

swift-init main start
EOF

cat << EOF > ~/bin/recreateaccounts
#!/bin/bash

# Replace swauthkey with whatever your super_admin key is (recorded in
# /etc/swift/proxy-server.conf).
swauth-prep -K swauthkey -A https://$SWIFT_IP:443/auth/
swauth-add-user -K swauthkey -A https://$SWIFT_IP:443/auth/ -a test tester testing
swauth-add-user -K swauthkey -A https://$SWIFT_IP:443/auth/ -a test2 tester2 testing2
swauth-add-user -K swauthkey -A https://$SWIFT_IP:443/auth/ test tester3 testing3
swauth-add-user -K swauthkey -A https://$SWIFT_IP:443/auth/ -a -r reseller reseller reseller
EOF

# Pag 25:
cat << EOF > ~/bin/startrest
#!/bin/bash

swift-init rest start
EOF

chmod +x ~/bin/*

# Pag 26
. ~/.bashrc
remakerings
cd ~/swift/trunk; ./.unittests
sudo bin/startmain
recreateaccounts

"
#/end user swift demo (!!)



################################################################################
# End of everything
touch /root/swift-saio-already-installed.touch
