FROM ubuntu:14.04
MAINTAINER Riccardo Carlesso "riccardo.carlesso+sakura@gmail.com"

ENV RICCARDO_APP sakura
ENV RICCARDO_DESCRIPTION "This is a cool dockerization of my swiss-army git-repo knife"
RUN apt-get update
RUN apt-get install -y facter apache2
RUN mkdir -p /usr/local/palladius-sakura/

# Testing these two...
ONBUILD ADD . /var/www/palladius-onbuild-sakura/
ONBUILD RUN cd /var/www/palladius-onbuild-sakura/ && make
ADD . /var/www/palladius-add-sakura/

EXPOSE 80

