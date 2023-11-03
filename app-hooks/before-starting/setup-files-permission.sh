#!/bin/sh
set -eu

if [ "$(id -u)" = 0 ]; then
    chown -R www-data:root /var/www/html
    chmod 750 www-data:root /var/www/html/data
fi
