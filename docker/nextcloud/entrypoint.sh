#!/bin/sh
set -eu

if expr "$1" : "apache" 1>/dev/null || [ "$1" = "php-fpm" ] || [ "${NEXTCLOUD_UPDATE:-0}" -eq 1 ]; then
    if [ "$(id -u)" = 0 ]; then
        echo "Updating permissions"
        (
            # chown -R www-data:root /var/www/html
            ( find /var/www/html -not -user www-data -print0 | xargs -P 0 -0 --no-run-if-empty chown --no-dereference www-data:root ) ; \
            # chmod 750 www-data:root /var/www/html/data
            ( find /var/www/html/data -type d -not -perm 750 -print0 | xargs -P 0 -0 --no-run-if-empty chmod 750 ) ; \
            ( find /var/www/html/data -type f -not -perm 650 -print0 | xargs -P 0 -0 --no-run-if-empty chmod 650 )
        ) &
    fi
fi

exec /entrypoint.sh "$@"
