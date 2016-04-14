#!/bin/bash
/etc/init.d/mysql restart
/etc/init.d/apache2 restart
cron -f
