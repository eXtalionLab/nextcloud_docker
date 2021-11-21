#!/bin/sh

until NGINX_ERROR=$(curl nginx 2>&1); do
    echo "Wait for server"
    sleep 1
done

echo "Run notify_push"

/var/www/html/custom_apps/notify_push/bin/x86_64/notify_push /var/www/html/config/config.php
