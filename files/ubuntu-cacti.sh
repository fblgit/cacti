#!/bin/bash
/data/ubuntu-apt.sh
DEBIAN_FRONTEND=noninteractive apt-get -qy install mysql-server apache2
cp /etc/cacti/debian.php /data/debian.php.org
cp /etc/cacti/spine.conf /data/spine.conf.org
DB_HOST=${$CACTI_DB_HOST:-localhost}
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
if [[ "$DB_HOST" -eq "localhost" ]]; then
  service mysql start
fi
DEBIAN_FRONTEND=noninteractive apt-get -qy install cacti-spine
if [[ -f /var/lib/mysql/.cacti ]]; then
  cp /var/lib/mysql/.cacti /etc/cacti/debian.php
fi
if [[ -f /var/lib/mysql/.spine ]]; then
  cp /var/lib/mysql/.spine /etc/cacti/spine.conf
fi
if [[ "$CACTI_DB_HOST" -eq "" ]]; then
  cp /etc/cacti/debian.php /var/lib/mysql/.cacti
  cp /etc/cacti/spine.conf /var/lib/mysql/.spine
else
  cp /data/spine.conf /etc/cacti/
  cp /data/debian.php /etc/cacti/
  cp /data/spine.conf /var/lib/mysql/.spine
  cp /data/debian.php /var/lib/mysql/.cacti
  if [[ "$DB_STARTUP" -eq "YES" ]]; then
    mysql -u $DB_USER -p$DB_PASS -P $DB_PORT -h $DB_HOST $DB_NAME < /data/cacti.sql
  fi
fi
service apache2 restart

echo "Foreground to Cron"
cron -f -L 8
