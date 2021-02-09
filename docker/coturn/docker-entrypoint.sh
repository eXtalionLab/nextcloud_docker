#!/bin/sh

if [ "$1" = "/usr/local/bin/turnserver" ]; then
    # Coturn can't reads from env
    sed -i "s/\(static-auth-secret=\).\+/\1${COTURN_SECRET}/" /etc/turnserver.conf
    sed -i "s/\(realm=\).\+/\1${COTURN_REALM}/" /etc/turnserver.conf
fi

exec "$@"
