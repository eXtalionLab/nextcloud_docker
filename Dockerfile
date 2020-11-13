FROM nextcloud:19-apache

RUN set -eux; \
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libmagickcore-6.q16-3-extra \
        smbclient \
    ; \
    rm -rf /var/lib/apt/lists/*;

RUN { \
        echo 'post_max_size=32M'; \
        echo 'upload_max_filesize=32M'; \
    } > /usr/local/etc/php/conf.d/uploads.ini
