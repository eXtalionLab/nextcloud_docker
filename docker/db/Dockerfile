# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target


# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG MARIADB_VERSION=10.5


# "mariadb" stage
FROM mariadb:${MARIADB_VERSION}

COPY nextcloud.cnf /etc/mysql/conf.d/zzz-nextcloud.cnf
