# User Documentation

## Services Provided

This project runs a WordPress website using three services:

- `nginx`: HTTPS entrypoint on port `443`.
- `wordpress`: WordPress application with PHP-FPM.
- `mariadb`: database used by WordPress.

NGINX is the only service exposed to the host. MariaDB and WordPress communicate only through the private Docker network.

## Start and Stop

From the project directory:

```sh
cd Inception
make
```

Stop the project:

```sh
make down
```

Remove containers, volumes, and persisted host data:

```sh
make fclean
```

## Access

Before opening the site, make sure the VM resolves the domain:

```text
127.0.0.1 sjoukni.42.fr
```

Website:

```text
https://sjoukni.42.fr
```

Administration panel:

```text
https://sjoukni.42.fr/wp-admin
```

The TLS certificate is self-signed, so the browser may show a warning. This is expected for the local project.

## Credentials

Non-sensitive settings are stored in:

```text
Inception/srcs/.env
```

Passwords are stored in Docker secret files:

```text
Inception/secrets/db_password.txt
Inception/secrets/db_root_password.txt
Inception/secrets/credentials.txt
```

`credentials.txt` contains the WordPress admin and normal user passwords.

## Health Checks

Show running containers:

```sh
cd Inception
make ps
```

Follow logs:

```sh
make logs
```

Check the containers directly:

```sh
docker ps
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Inside the WordPress container, useful checks are:

```sh
docker exec -it wordpress bash
cd /var/www/html
wp core is-installed --allow-root
wp user list --allow-root
```
