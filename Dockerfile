# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target


# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG NEXTCLOUD_VERSION=20


# "nextcloud" stage
FROM nextcloud:${NEXTCLOUD_VERSION}-fpm AS nextcloud


RUN set -eux; \
    \
    ln -sr $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
COPY docker/nextcloud/conf.d/nextcloud.ini $PHP_INI_DIR/conf.d/zzz-nextcloud.ini
COPY docker/nextcloud/php-fpm.d/nextcloud.conf $PHP_INI_DIR/../php-fpm.d/zzz-nextcloud.conf


RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        libmagickcore-6.q16-6-extra \
        procps \
        smbclient \
        supervisor \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libbz2-dev \
        libc-client-dev \
        libkrb5-dev \
        libsmbclient-dev \
    ; \
    \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
    docker-php-ext-install \
        bz2 \
        imap \
    ; \
    pecl install \
        smbclient \
    ; \
    \
    docker-php-ext-enable smbclient; \
    \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '/=>/ { print $3 }' \
        | sort -u \
        | xargs -r dpkg-query -S \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual; \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*


COPY docker/nextcloud/cron.sh /nextcloud-cron.sh
COPY docker/nextcloud/entrypoint.sh /nextcloud-entrypoint.sh
RUN set -eux; \
    \
    chmod +x /nextcloud-cron.sh; \
    chmod +x /nextcloud-entrypoint.sh; \
    \
    echo '*/10 * * * * /nextcloud-cron.sh' >> /var/spool/cron/crontabs/www-data


RUN mkdir -p \
    /var/log/supervisord \
    /var/run/supervisord \
;

COPY docker/nextcloud/supervisord.conf /

ENV NEXTCLOUD_UPDATE=1

ENTRYPOINT ["/nextcloud-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
