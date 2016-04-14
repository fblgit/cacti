#name of container: ubuntu-cacti
#version of container 0.1
FROM fblgit/ubuntu-base
MAINTAINER FBLGIT
VOLUME /var/lib/cacti/rra
RUN sed -i '/session    required   pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/cron
COPY files/ubuntu-cacti.sh /data/ubuntu-cacti.sh
COPY files/start-cacti.sh /data/start-cacti.sh
RUN chmod +x /data/ubuntu-cacti.sh
RUN chmod +x /data/start-cacti.sh
ENTRYPOINT ["/data/ubuntu-cacti.sh"]
CMD ["mysqld"]
