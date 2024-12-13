#!/bin/sh
set -eu

if [ "${NEXTCLOUD_DEFAULT_PHONE_REGION}" != "" ]; then
    echo "Updating default phone region"

    php /var/www/html/occ config:system:set \
        default_phone_region \
        --value="${NEXTCLOUD_DEFAULT_PHONE_REGION}"
fi

if [ "${NEXTCLOUD_MAINTENANCE_WINDOW_START}" != "" ]; then
    echo "Updating maintenance window start"

    php /var/www/html/occ config:system:set \
        maintenance_window_start \
        --type=integer \
        --value="${NEXTCLOUD_MAINTENANCE_WINDOW_START}"
fi
