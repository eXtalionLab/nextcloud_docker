# Nextcloud

It's a simply as possible `docker compose` stack to run a
[Nextcloud](https://www.nextcloud.com) for **development** and for
**production**.

---

- [Requirements](#requirements)
- [Run](#run)
	- [Fresh run](#fresh-run)
	- [Run installed cloud](#run-installed-cloud)
	- [Production](#production)
	- [Docker envs](#docker-envs)
	- [Log level](#log-level)
- [Improving Nextcloud Previews](#improving-nextcloud-previews)
- [Full Text Search](#full-text-search)
- [Collabora online](#collabora-online)
- [Talk (STUN / TURN)](#talk-stun--turn)
- [Notify Push](#notify-push)
- [Reverse proxy](#reverse-proxy)
- [Backup](#backup)
- [Update / Deploy](#update--deploy)
- [Debug](#debug)

## Requirements

To run this you just need a [docker](https://www.docker.com/get-started/) and
[docker compose](https://github.com/docker/compose#quick-start).

## Run

You can install a fresh instance of Nextcloud or restore your already installed
cloud from dump/backup.

### Fresh run

When you want to run fresh instance of nextcloud:

**Extra!** Create a **.env** file (use **.env.dist** as starter file,
`cp .env.dist .env`) and setup values.

1. Run `docker compose up [-d]`.
2. Wait for download and build images.
3. Wait for install a fresh Nextcloud instance.
4. Stop (`Ctrl+C`) and run `docker compose up` again to correct setup files
permissions.
5. Goto [NEXTCLOUD_HOST:NEXTCLOUD_PORT](http://localhost/) domain and play with
your new cloud.

You can also run command to add "missing" indexes in the database:

```bash
bin/occ db:add-missing-indices
```

### Run installed cloud

When you have a dump of your already installed Nextcloud instance:

1. Create a **.env** file (use **.env.dist** as starter file,
`cp .env.dist .env`) and setup **required** values:
	- `MYSQL_DATABASE` (`dbname`),
	- `MYSQL_PASSWORD` (`dbpassword`),
	- `MYSQL_USER` (`dbuser`),
	- `NEXTCLOUD_DEFAULT_PHONE_REGION` (`default_phone_region`),
	- `NEXTCLOUD_MAINTENANCE_WINDOW_START` (`maintenance_window_start`),
	- `NEXTCLOUD_TRUSTED_DOMAINS` (`trusted_domains`),
	- `REDIS_HOST_PASSWORD` (`redis.password`).
They should have the same values as in current **config/config.php**.
2. Move your database dump file(s) into **initdb.d/** directory.
3. Move your config files into **config/** directory.
4. Move your custom apps into **apps/** directory.
5. Move your data files into **data/** directory.
6. Move your nextcloud files into **nextcloud/** directory.
7. Run `docker compose up [-d]`.
8. Wait for download and build images.
9. Wait when `db` service will load dump file(s) into the database.
**Note!** When you goto the cloud before database is loaded you will got an
error. Please be patient and wait for database.
10. Goto [http://localhost/](http://localhost/) domain and play with your new
cloud.

### Production

If you want to run **prod**uction environment

1. Uncomment line `#COMPOSE_FILE=compose.yml:compose.prod.yml` in **.env**
file. It tells to `docker compose` to use those files instead of default
**docker compose.yml** and  **docker compose.override.yml** (they're good for
**dev**elopment).
2. Rebuild images with `docker compose build [--pull]`.
3. Run new stack `docker compose up [-d]`.

### Docker envs

`NEXTCLOUD_HOST` allow to change a host on which `nginx` services is
listening. Default it's `127.0.0.1` so only you can connect from your local
machine to the cloud. Setup `0.0.0.0` to allow others from the same network to
connect to your cloud (for example to test cloud on your mobile).

Other environments are described
[here](https://github.com/nextcloud/docker/tree/master#auto-configuration-via-environment-variables).

### Log level

To "increase" performance you can set log level to `error`:

```bash
bin/occ log:manage --level=error
```

### Development mailer

In **dev** environment you can use `mailer` service to catch all emails sent. In
**Basic settings** setup:

- `Send mode` to `SMTP`,
- `Encryption` to `None`,
- `From address` to your email address,
- `Server address` to `mailer` and port to `1025`.

Click `Send email` to test if it works.

## Improving Nextcloud Previews

According to this [article](https://ownyourbits.com/2019/06/29/understanding-and-improving-nextcloud-previews/)
Preview mechanism need some tuning.

Install Nextcloud [app](https://apps.nextcloud.com/apps/previewgenerator) and
setup recommended configurations:

```bash
bin/occ config:app:set previewgenerator squareSizes --value="32 256"
bin/occ config:app:set previewgenerator widthSizes  --value="256 384"
bin/occ config:app:set previewgenerator heightSizes --value="256"
bin/occ config:system:set preview_max_x --value 2048
bin/occ config:system:set preview_max_y --value 2048
bin/occ config:system:set jpeg_quality --value 60
bin/occ config:app:set preview jpeg_quality --value="60"
```

If you want to start from scratch you can delete preview folder:

```bash
rm -rf ./data/appdata_*/preview
```

And regenerate previews first time by:

```bash
bin/occ preview:generate-all -vvv
```

## Full Text Search

To improve search result we can install:

- [fulltextsearch](https://apps.nextcloud.com/apps/fulltextsearch)
- [files_fulltextsearch](https://apps.nextcloud.com/apps/files_fulltextsearch)
- [fulltextsearch_elasticsearch](https://apps.nextcloud.com/apps/fulltextsearch_elasticsearch)

We have to run `elasticsearch` service. Add `:docker/elasticsearch/compose.yml`
to `COMPOSE_FILE` environment.

Goto [settings](http://localhost:80/settings/admin/fulltextsearch), select
`Elasticsearch` from select box, as an address type `http://elasticsearch:9200`
and setup index to `nextcloud_index`.

For first index run:

```bash
bin/occ fulltextsearch:index
```

## Collabora online

If you want to run collabora online locally and you don't have a reverse proxy,
you have to add `nginx` and `collabora` to your **/etc/hosts**:

```bash
127.0.0.1 collabora
127.0.0.1 nginx
```

For nextcloud (docker service) collabora is available under `collabora` host and
it has to be the same host for a client (your browser).

For collabora (docker service) nextcloud is available under `nginx` host and you
have to access nextcloud instance via [http://nginx:$NEXTCLOUD_PORT](http://nginx:80).

---

We have to run `collabora` service. Add `:docker/collabora/compose.yml` to
`COMPOSE_FILE` environment.

You can also change/setup other environments in **.env** file:

```bash
###> Collabora ###
COLLABORA_PORT=9980

# Go and read https://www.collaboraoffice.com/code/docker/and
# https://github.com/CollaboraOnline/online/blob/master/docker/from-packages/scripts/start-collabora-online.sh
# to see all env

COLLABORA_DICTIONARIES=en
# Value other then "set" will disable warning/info messages of LOKit
COLLABORA_SAL_LOG=set
# Value other then "set" won't generate ssl cert
COLLABORA_DONT_GEN_SSL_CERT=
COLLABORA_CERT_DOMAIN=collabora
# Collabora domain (without reverse proxy it's docker service)
COLLABORA_SERVER_NAME=collabora:9980
# Nextcloud domain (without reverse proxy it's docker service)
COLLABORA_DOMAIN=nginx
# Extra loolwsd command line parameter. To learn about all possible options,
# refer to the self-documented /etc/loolwsd/loolwsd.xml
#   docker compose exec collabora cat /etc/loolwsd/loolwsd.xml
COLLABORA_EXTRA_PARAMS=--o:admin_console.enable=false --o:ssl.enable=false
# To enable the admin console feature of CODE remove admin_console.enbale option
# $COLLABORA_SERVER_NAME/loleaflet/dist/admin/admin.html
COLLABORA_USERNAME=root
COLLABORA_PASSWORD=CHANGE_ME
###< Collabora ###
```

Install [richdocuments](https://apps.nextcloud.com/apps/richdocuments),
goto [settings](http://nginx:80/settings/admin/richdocuments), select
`Use your own server` and as an url put `http://collabora:9980`.

**Done!**

## Talk (STUN / TURN)

If you have install talk [app](https://apps.nextcloud.com/apps/spreed) and you
want to "increase" performance and have video calls, you have to set up your own
STUN/TURN server.

We have to run `coturn` service. Add `:docker/coturn/compose.yml` to
`COMPOSE_FILE` environment.

You can also change/setup other environments in **.env** file:

```bash
###> Coturn ###
COTURN_PORT=3478
COTURN_SECRET=CHANGE_ME
# Your nextcloud domain
COTURN_REALM=localhost
###< Coturn ###
```

Goto [settings](http://localhost:80/settings/admin/talk) and set:

- `STUN server` to `your-server-ip:$COTURN_PORT`,
- `TURN server` to `your-server-ip:$COTURN_PORT`,
- `TURN secret` to `$COTURN_SECRET`.

## Notify Push

To configure [notify_push](https://github.com/nextcloud/notify_push) app:

- Install the `notify_push` app from the appstore,
- Restart `nextcloud` service (`docker compose restart nextcloud`),
- set the url of the push server (`bin/occ notify_push:setup http://domain/push`)

If you got **push server is not a trusted proxy** then you have to add displayed
proxies in **config/config.php** to `trusted_proxies`.

## Reverse proxy

Basic nginx configuration for reverse proxy is available
[here](https://www.digitalocean.com/community/tools/nginx?domains.0.server.domain=nextcloud.example.com&domains.0.server.redirectSubdomains=false&domains.0.https.hstsPreload=true&domains.0.php.php=false&domains.0.reverseProxy.reverseProxy=true&domains.0.reverseProxy.proxyPass=http%3A%2F%2F127.0.0.1%3A%24NEXTCLOUD_PORT&domains.0.routing.root=false&domains.0.logging.accessLog=true&domains.0.logging.errorLog=true&domains.1.server.domain=collabora.example.com&domains.1.server.redirectSubdomains=false&domains.1.https.hstsPreload=true&domains.1.php.php=false&domains.1.reverseProxy.reverseProxy=true&domains.1.reverseProxy.proxyPass=http%3A%2F%2F127.0.0.1%3A%24COLLABORA_PORT&domains.1.routing.root=false&domains.1.logging.accessLog=true&domains.1.logging.errorLog=true).

Update `Server > Domain` names and `Reverse proxy > proxy_pass` ports (read
ports from your **.env** file).

Remove `include nginxconfig.io/security.conf;` from nextcloud domain conf.
Docker nginx service conf is build base on
[Nextcloud example](https://github.com/nextcloud/docker/blob/master/.examples/docker compose/insecure/mariadb-cron-redis/fpm/web/nginx.conf).

In **.env** file you have to change:

```bash
NEXTCLOUD_TRUSTED_DOMAINS=nextcloud.example.com
COLLABORA_CERT_DOMAIN=collabora.example.com
COLLABORA_SERVER_NAME=collabora.example.com
COLLABORA_DOMAIN=nextcloud.example.com
```

If you have install nextcloud already, in **./config/config.php**:

- add `nextcloud.example.pl` to `trusted_domains` array,
- change `overwrite.cli.url` to `nextcloud.example.pl`.

If you have setup collabora online, you have to update
`URL (and Port) of Collabora Online-server` to `collabora.example.com`.

Reload docker:

```bash
docker compose up [-d]
```

## Backup

To make a backup we're using a
[docker-backup](https://github.com/eXtalionLab/docker-backup) tool which use
[BorgBackup](https://www.borgbackup.org/) under hood.

Create a **.docker-backup** file (use **.docker-backup.dist** as starter file,
`cp .docker-backup.dist .docker-backup`) and setup values. Refer to
[documentation](https://github.com/eXtalionLab/docker-backup#docker-backup).

## Update / Deploy

Setup `COMPOSE_FILE` to `docker compose.yml:docker compose.prod.yml`. Also if
you want to run other services (`elasticsearch`, `collabora`, `coturn`) add their
**compose.yml** too. See
[here](https://docs.docker.com/compose/environment-variables/envvars/#compose_file).

Update images names prefix (**.env** `IMAGES_PREFIX`) which point to your hub.

Run:

```bash
docker compose build --pull
```

If you didn't build images on the server run:

```bash
docker compose push
```

On the server run:

```bash
docker compose pull
docker compose up -d
```

## Debug

If you want to debug a cloud with [xdebug](https://xdebug.org/):

- be sure you're running **dev** environment (and images),
- add/setup `debug` to `XDEBUG_MODE`,
- reload docker with `docker compose up -d`.

Now you're ready to remote debugging.
