#!/bin/bash

if [ "${1:0:1}" == '-' ]; then
    # Coturn can't reads from env
    sed -i "s/\(static-auth-secret=\).\+/\1${COTURN_SECRET}/" /etc/turnserver.conf
    sed -i "s/\(realm=\).\+/\1${COTURN_REALM}/" /etc/turnserver.conf
fi

docker-entrypoint.sh "$@"
