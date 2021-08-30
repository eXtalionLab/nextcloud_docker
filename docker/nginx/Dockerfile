# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target


# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG NGINX_VERSION=1.20


# "nginx" stage
FROM nginx:${NGINX_VERSION}-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
