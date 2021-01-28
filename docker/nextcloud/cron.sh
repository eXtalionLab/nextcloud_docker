#!/bin/sh
set -eu

isPreviewApp=$(php -f /var/www/html/occ | grep preview:pre-generate)

if [ "$isPreviewApp" != '' ]; then
    echo "Preview pre-generate"
    php -f /var/www/html/occ preview:pre-generate
fi
