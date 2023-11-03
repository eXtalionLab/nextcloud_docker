#syntax=docker/dockerfile:1.4

# Adapted from https://github.com/dunglas/symfony-docker


# Versions
# hadolint ignore=DL3007
FROM nextcloud:26-fpm AS nextcloud_upstream
FROM composer/composer:2-bin AS composer_upstream
FROM mlocati/php-extension-installer AS php_extension_installer_upstream


# The different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target


# Base nextcloud image
FROM nextcloud_upstream as nextcloud_base

WORKDIR /var/www/html

# persistent / runtime deps
# hadolint ignore=DL3008
RUN apt-get update; \
	apt-get install -y --no-install-recommends \
		ffmpeg \
		procps \
		smbclient \
		supervisor \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# php extensions installer: https://github.com/mlocati/docker-php-extension-installer
COPY --from=php_extension_installer_upstream /usr/bin/install-php-extensions /usr/local/bin/

RUN set -eux; \
	install-php-extensions \
		bz2 \
		imap \
		smbclient \
	;

COPY docker/nextcloud/conf.d/nextcloud.ini $PHP_INI_DIR/conf.d/zzz-nextcloud.ini
COPY docker/nextcloud/php-fpm.d/nextcloud.conf $PHP_INI_DIR/../php-fpm.d/zzz-nextcloud.conf

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

COPY --from=composer_upstream /composer /usr/bin/composer

###> cron ###
RUN set -eux; \
	\
	mkdir -p /var/log/supervisord; \
	mkdir -p /var/run/supervisord

COPY docker/nextcloud/supervisord.conf /
COPY docker/nextcloud/cron.sh /nextcloud-cron.sh

RUN chmod +x /nextcloud-cron.sh
RUN echo '*/10 * * * * /nextcloud-cron.sh' >> /var/spool/cron/crontabs/www-data
###< cron ###

###> notify_push ###
COPY docker/nextcloud/notify_push.sh /notify_push.sh
RUN set -eux; \
	chmod +x /notify_push.sh

EXPOSE 7867
###< notify_push ###

###> custom ###
###< custom ###

ENV NEXTCLOUD_UPDATE=1

CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]

# Dev nextcloud image
FROM nextcloud_base AS nextcloud_dev

ENV XDEBUG_MODE=develop

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN apt-get update; \
	apt-get install -y --no-install-recommends \
		zip \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	install-php-extensions \
		xdebug \
	;

COPY docker/nextcloud/conf.d/nextcloud.dev.ini $PHP_INI_DIR/conf.d/zzz-nextcloud.dev.ini

# Prod nextcloud image
FROM nextcloud_base AS nextcloud_prod

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY docker/nextcloud/conf.d/nextcloud.prod.ini $PHP_INI_DIR/conf.d/zzz-nextcloud.prod.ini
