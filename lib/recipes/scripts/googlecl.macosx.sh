
# http://www.freshblurbs.com/blog/2010/06/19/installing-googlecl-mac.html

mkdir ~/src
cd ~/src
curl -O http://gdata-python-client.googlecode.com/files/gdata-2.0.10.tar.gz
tar xzvf gdata-2.0.10.tar.gz
cd gdata-2.0.10
sudo python setup.py install

curl -O https://googlecl.googlecode.com/files/googlecl-0.9.14.tar.gz
tar xzvf googlecl-0.9.14.tar.gz
cd googlecl-0.9.14
sudo python setup.py install

