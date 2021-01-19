# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target


# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG ELASTICSEARCH_VERSION=7.10.1


# "elasticsearch" stage
FROM elasticsearch:${ELASTICSEARCH_VERSION} AS elasticsearch


RUN set -eux; \
    \
    bin/elasticsearch-plugin install --batch ingest-attachment
