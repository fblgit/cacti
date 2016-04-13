#name of container: ubuntu-base
#version of container 0.1
FROM fblgit/ubuntu-base
MAINTAINER FBLGIT
VOLUME /var/lib/cacti/rra
COPY files/ubuntu-cacti.sh /data/ubuntu-cacti.sh
RUN chmod +x /data/ubuntu-cacti.sh && \
    /data/ubuntu-cacti.sh
