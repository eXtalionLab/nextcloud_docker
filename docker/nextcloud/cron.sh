#!/bin/bash
set -eu

# See: https://ownyourbits.com/2019/06/29/understanding-and-improving-nextcloud-previews/
isPreviewApp=$(php -f /var/www/html/occ | grep preview:pre-generate)

if [[ $isPreviewApp != '' ]]; then
    echo "Preview pre-generate"
    php -f /var/www/html/occ preview:pre-generate
fi
