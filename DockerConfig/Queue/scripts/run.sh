#!/bin/bash

cd /var/www/html
composer install
service cron start
crontab -u www-data /etc/cron.d/schedule
/usr/bin/supervisord
