#!/bin/bash
DEBIAN_FRONTEND=noninteractive apt-get install mysql-server cacti-spine
echo "<?php
$database_type = \\"mysql\";
$database_default = \"$CACTI_DB_NAME\";
$database_hostname = \"$CACTI_DB_HOST\";
$database_username = \"$CACTI_DB_USER\";
$database_password = \"$CACTI_DB_PASSWORD\";
$database_port = \"$CACTI_DB_PORT\";
$database_ssl = false;
?>">/data/cacti.php
echo "DB_Host         $CACTI_DB_HOST
DB_Database     $CACTI_DB_NAME
DB_User         $CACTI_DB_USER
DB_Pass         $CACTI_DB_PASSWORD
DB_Port         $CACTI_DB_PORT">/data/spine.conf
