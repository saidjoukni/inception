# Inception Bonus Checks

Use this file during defense to explain and verify the bonus services.

## Check Running Containers

From the project directory:

```sh
cd Inception
make ps
```

You should see these bonus containers running:

```text
redis
ftp
static_site
adminer
portainer
```

## Redis Cache For WordPress

Redis is used as a persistent object cache for WordPress. WordPress connects to the `redis` container through the Docker network.

Check Redis:

```sh
docker compose -p inception -f srcs/docker-compose.yml exec redis redis-cli ping
```

Expected result:

```text
PONG
```

Check the WordPress Redis plugin:

```sh
docker compose -p inception -f srcs/docker-compose.yml exec wordpress wp redis status --allow-root --path=/var/www/html
```

Expected important lines:

```text
Status: Connected
Ping: PONG
WP_REDIS_HOST: "redis"
```

## FTP Server

The FTP container points to the same volume used by WordPress:

```yaml
volumes:
  - wordpress_data:/var/www/html
```

FTP credentials:

```text
host: sjoukni.42.fr
port: 21
user: sjoukni
password: said
```

Command test:

```sh
curl --ftp-pasv ftp://sjoukni:said@127.0.0.1/
```

Expected result: you should see WordPress files, for example:

```text
wp-config.php
wp-content
wp-admin
wp-login.php
```

This proves that FTP is connected to the WordPress website volume.

## Static Website

The static website is served by the `static_site` container and proxied through Nginx.

Open in the browser:

```text
https://sjoukni.42.fr/static/
```

Or test with:

```sh
curl -k -I https://sjoukni.42.fr/static/
```

Expected result:

```text
HTTP/1.1 200 OK
```

## Adminer

Adminer is used to inspect and manage the MariaDB database from a web interface.

Open:

```text
https://sjoukni.42.fr/adminer/
```

Do not use `localhost` as the server. In Adminer, `localhost` means inside the Adminer container, but MariaDB is in a separate container. Use `mariadb`.

Login values:

```text
System: MySQL / MariaDB
Server: mariadb
Username: wp_user
Password: said
Database: wordpress_db
```

To prove the database is not empty, open the `wordpress_db` database and check tables such as:

```text
wp_users
wp_posts
wp_options
wp_comments
```

## Free Choice Service: Portainer

Portainer is the free choice service.

Open:

```text
https://portainer.sjoukni.42.fr
```

If Portainer says it timed out or does not show the setup page, restart only Portainer:

```sh
cd Inception
docker compose -p inception -f srcs/docker-compose.yml restart portainer
```

Explanation for defense:

Portainer is useful because it provides a web interface for Docker. It helps inspect containers, images, networks, volumes, and logs without using only command-line tools. It is useful for monitoring and managing the infrastructure of the project.

## If Nginx Port Is Changed

If the reviewer asks you to change the public Nginx port, for example from `443` to `4443`, update `srcs/docker-compose.yml`:

```yaml
ports:
  - "4443:443"
```

Then update `DOMAIN_NAME` in `srcs/.env`:

```env
DOMAIN_NAME=sjoukni.42.fr:4443
```

Rebuild and restart:

```sh
cd Inception
make down
make up
```

Then use URLs with the new port:

```text
https://sjoukni.42.fr:4443
https://sjoukni.42.fr:4443/static/
https://sjoukni.42.fr:4443/adminer/
```

Important: WordPress must know the new port. Otherwise it redirects back to `https://sjoukni.42.fr` on port `443`.
