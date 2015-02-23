FROM ubuntu:14.04
#FROM ubuntu:12.04
MAINTAINER Riccardo Carlesso "riccardo.carlesso+sakura@gmail.com"

ENV RICCARDO_APP sakura
ENV RICCARDO_DESCRIPTION "This is a cool dockerization of my swiss-army git-repo knife. Seems not to work with 14:04"
# Copied from: https://github.com/paulczar/docker-apache2/blob/master/Dockerfile
env APACHE_RUN_USER    www-data
env APACHE_RUN_GROUP   www-data
env APACHE_PID_FILE    /var/run/apache2.pid
env APACHE_RUN_DIR     /var/run/apache2
env APACHE_LOCK_DIR    /var/lock/apache2
env APACHE_LOG_DIR     /var/log/apache2
env LANG               C
env SAKURA_DOCKER_VAR  2.2.1-20150219

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 libapache2-mod-php5 php5-mysql php5-gd php-pear php-apc php5-curl curl lynx-cur
#RUN apt-get install -y facter
RUN apt-get install -y netcat vim bash-completion
RUN sed -i /etc/apache2/sites-enabled/000-default.conf -e 's/#ServerName www.example.com/ServerName sakura.palladius.eu/'
RUN update-rc.d apache2 enable
#RUN service apache2 start
RUN mkdir -p /usr/local/palladius-sakura/
RUN echo ${SAKURA_DOCKER_VAR} > /root/SAKURA_DOCKER_VERSION

# Testing these two...
#ONBUILD ADD . /var/www/palladius-onbuild-sakura/
#ONBUILD RUN cd /var/www/palladius-onbuild-sakura/ && make
ADD . /var/www/html/
ADD . /usr/local/palladius-sakura/

CMD ["apache2", "-D", "FOREGROUND"]
#CMD service apache2 start
EXPOSE 80

###########################################################################################
# Inspiration
# https://medium.com/dev-tricks/apache-and-php-on-docker-44faef716150
###########################################################################################
