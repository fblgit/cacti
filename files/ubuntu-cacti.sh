#!/bin/bash
/data/ubuntu-apt.sh
DEBIAN_FRONTEND=noninteractive apt-get -qy install mysql-server cacti-spine
cp /etc/cacti/debian.php /data/debian.php.org
cp /etc/cacti/spine.conf /data/spine.conf.org
DB_HOST=${$CACTI_DB_HOST:-127.0.0.1}
DB_PORT=${CACTI_DB_PORT:-3306}
DB_NAME=${CACTI_DB_NAME:-cacti}
DB_USER=${CACTI_DB_USER:-cacti}
DB_PASS=${CACTI_DB_PASSWORD:-FBLCACTIDocker}
echo "<?php
\$database_type = \"mysql\";
\$database_default = \"$DB_NAME\";
\$database_hostname = \"$DB_HOST\";
\$database_username = \"$DB_USER\";
\$database_password = \"$DB_PASS\";
\$database_port = \"$DB_PORT\";
\$database_ssl = false;
?>">/data/debian.php
echo "DB_Host         $DB_HOST
DB_Database     $DB_NAME
DB_User         $DB_USER
DB_Pass         $DB_PASS
DB_Port         $DB_PORT">/data/spine.conf
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
service rsyslog start
service apache2 start
service mysql start
if [[ "$CACTI_DB_HOST" -eq "" ]]; then
  if [[ ! -f /data/.granted ]] ; then
    sleep 5
    cp /data/spine.conf /etc/cacti/
    cp /data/debian.php /etc/cacti/
    GRANT="GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';"
    echo $GRANT
    mysql << EOF
CREATE DATABASE cacti;
$GRANT
FLUSH PRIVILEGES;
EOF
    touch /data/.granted
  fi
fi
echo "Deliver to Cron"
cron -f
echo "Cron Running"
