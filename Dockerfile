# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target


# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG NEXTCLOUD_VERSION=20


# "nextcloud" stage
FROM nextcloud:${NEXTCLOUD_VERSION}-fpm-alpine AS nextcloud


RUN set -eux; \
    \
    ln -s $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
COPY docker/nextcloud/conf.d/nextcloud.ini $PHP_INI_DIR/conf.d/nextcloud.ini


RUN set -ex; \
    \
    apk add --no-cache \
        ffmpeg \
        imagemagick \
        procps \
        samba-client \
        supervisor \
    ;

RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        bzip2-dev \
        imap-dev \
        krb5-dev \
        openssl-dev \
        samba-dev \
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
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --virtual .nextcloud-phpext-rundeps $runDeps; \
    apk del .build-deps


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
