# Nextcloud with docker

## Install

Copy **.env.dist** to **.env** and edit values to your needs:

```
cp .env.dist .env
vim .env
```

Build docker images:

```
docker-compose -f docker-compose.build.yml build --pull
```

Run docker stock:

```
docker-compose up [-d]
```

Goto [http://localhost:$NEXTCLOUD_PORT](http://localhost:80) and follow
Nextcloud installation instructions.

### Log level

To "increase" performance you can set log level to `error`:

```
bin/occ log:manage --level=error
```

## Improving Nextcloud Previews

According to this [article](https://ownyourbits.com/2019/06/29/understanding-and-improving-nextcloud-previews/)
Preview mechanism need some tuning.

Install Nextcloud [app](https://apps.nextcloud.com/apps/previewgenerator) and
setup recommended configurations:

```
bin/occ config:app:set previewgenerator squareSizes --value="32 256"
bin/occ config:app:set previewgenerator widthSizes  --value="256 384"
bin/occ config:app:set previewgenerator heightSizes --value="256"
bin/occ config:system:set preview_max_x --value 2048
bin/occ config:system:set preview_max_y --value 2048
bin/occ config:system:set jpeg_quality --value 60
bin/occ config:app:set preview jpeg_quality --value="60"
```

If you want to start from scratch you can delete preview folder:

```
rm -rf ./data/appdata_*/preview
```

And regenerate previews first time by:

```
bin/occ preview:generate-all -vvv
```

## Full Text Search

To improve search result we can install:

- [fulltextsearch](https://apps.nextcloud.com/apps/fulltextsearch)
- [files_fulltextsearch](https://apps.nextcloud.com/apps/files_fulltextsearch)
- [fulltextsearch_elasticsearch](https://apps.nextcloud.com/apps/fulltextsearch_elasticsearch)

goto [settings](http://localhost:80/settings/admin/fulltextsearch), select
`Elasticsearch` from select box, as an address type `http://elasticsearch:9200`
and setup index to `nextcloud_index`.

For first index run:

```
bin/occ fulltextsearch:index
```

## Collabora online

If you want to run collabora online locally and you don't have a reverse proxy,
you have to add `nginx` and `collabora` to your **/etc/hosts**:

```
127.0.0.1 collabora
127.0.0.1 nginx
```

For nextcloud (docker service) collabora is avaliable under `collabora` host and
it has to be the same host for a client (your browser).

For collabora (docker service) nextcloud is avaliable under `nginx` host and you
have to access nextcloud instance via [http://nginx:$NEXTCLOUD_PORT](http://nginx:80).

---

Install [richdocuments](https://apps.nextcloud.com/apps/richdocuments),
goto [settings](http://nginx:80/settings/admin/richdocuments), select
`Use your own server` and as an url put `http://collabora:9980`.

**Done!**

## Reverse proxy

Basic nginx configuration for reverse proxy is avaliable
[here](https://www.digitalocean.com/community/tools/nginx?domains.0.server.domain=nextcloud.example.com&domains.0.server.redirectSubdomains=false&domains.0.https.hstsPreload=true&domains.0.php.php=false&domains.0.reverseProxy.reverseProxy=true&domains.0.reverseProxy.proxyPass=http%3A%2F%2F127.0.0.1%3A%24NEXTCLOUD_PORT&domains.0.routing.root=false&domains.0.logging.accessLog=true&domains.0.logging.errorLog=true&domains.1.server.domain=collabora.example.com&domains.1.server.redirectSubdomains=false&domains.1.https.hstsPreload=true&domains.1.php.php=false&domains.1.reverseProxy.reverseProxy=true&domains.1.reverseProxy.proxyPass=http%3A%2F%2F127.0.0.1%3A%24COLLABORA_PORT&domains.1.routing.root=false&domains.1.logging.accessLog=true&domains.1.logging.errorLog=true).

Update `Server > Domain` names and `Reverse proxy > proxy_pass` ports (read
ports from your **.env** file).

Remove `include nginxconfig.io/security.conf;` from nextcloud domain conf.
Docker nginx service conf is build base on
[Nextcloud example](https://github.com/nextcloud/docker/blob/master/.examples/docker-compose/insecure/mariadb-cron-redis/fpm/web/nginx.conf).

In **.env** file you have to change:

```
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

```
docker-compose up [-d]
```

## Update / Deploy

Update images names (**.env** `*_IMAGE`) which point to your hub.

Run:

```
docker-compose -f docker-compose.build.yml build --pull
```

If you didn't build images on the server run:

```
docker-compose -f docker-compose.build.yml push
```

On the server run:

```
docker-compose pull
docker-compose up -d
```
