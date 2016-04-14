#!/bin/bash
/data/ubuntu-apt.sh
DEBIAN_FRONTEND=noninteractive apt-get -qy install mysql-server cacti-spine
cp /etc/cacti/debian.php /data/debian.php.org
cp /etc/cacti/spine.conf /data/spine.conf.org
echo "<?php
\$database_type = \"mysql\";
\$database_default = \"$CACTI_DB_NAME\";
\$database_hostname = \"$CACTI_DB_HOST\";
\$database_username = \"$CACTI_DB_USER\";
\$database_password = \"$CACTI_DB_PASSWORD\";
\$database_port = \"$CACTI_DB_PORT\";
\$database_ssl = false;
?>">/data/debian.php
echo "DB_Host         $CACTI_DB_HOST
DB_Database     $CACTI_DB_NAME
DB_User         $CACTI_DB_USER
DB_Pass         $CACTI_DB_PASSWORD
DB_Port         $CACTI_DB_PORT">/data/spine.conf
service mysql start
sleep 3
if [ "$CACTI_DB_USER" -ne "" ]; then
  cp /data/spine.conf /etc/cacti/
  cp /data/debian.php /etc/cacti/
  GRANT="GRANT ALL PRIVILEGES ON $CACTI_DB_HOST.* TO $CACTI_DB_USER@% IDENTIFIED BY \'$CACTI_DB_PASSWORD\';"
  mysql -u root << EOF
  $GRANT
  EOF
  sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
fi

/etc/init.d/apache2 start

cron -f
