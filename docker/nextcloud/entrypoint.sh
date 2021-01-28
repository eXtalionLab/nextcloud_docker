#!/bin/sh
set -eu

if expr "$1" : "apache" 1>/dev/null || [ "$1" = "php-fpm" ] || [ "${NEXTCLOUD_UPDATE:-0}" -eq 1 ]; then
    if [ "$(id -u)" = 0 ]; then
        chown -R www-data:root /var/www/html
    fi
fi

exec /entrypoint.sh "$@"
