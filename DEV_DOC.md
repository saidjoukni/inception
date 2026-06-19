# Developer Documentation

## Prerequisites

The project is expected to run inside a Linux virtual machine with:

- Docker
- Docker Compose v2
- `make`
- permissions to create `/home/sjoukni/data`

The local domain should point to the VM:

```text
127.0.0.1 sjoukni.42.fr
```

## Project Layout

```text
Inception/
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

Each service has its own Dockerfile and configuration files.

## Configuration

`Inception/srcs/.env` stores non-sensitive variables:

- `MYSQL_DATABASE`
- `MYSQL_USER`
- `DOMAIN_NAME`
- `WP_TITLE`
- WordPress usernames and emails
- paths to mounted secret files

Passwords are read from:

- `/run/secrets/db_password`
- `/run/secrets/db_root_password`
- `/run/secrets/credentials`

These files are mounted by Docker Compose from `Inception/secrets`.

## Build and Launch

Build and start everything:

```sh
cd Inception
make
```

Equivalent Compose command:

```sh
docker compose -p inception -f srcs/docker-compose.yml up --build -d
```

The Makefile creates:

```text
/home/sjoukni/data/mariadb
/home/sjoukni/data/wordpress
```

before Compose starts the containers.

## Management Commands

```sh
make build    # build images only
make up       # create data folders, build, and start
make down     # stop and remove containers
make stop     # stop containers without removing them
make restart  # restart the stack
make ps       # show container state
make logs     # follow logs
make clean    # down with orphan removal
make fclean   # down, remove volumes, remove host data
make re       # full rebuild from empty data
```

## Data Persistence

The Compose file defines two named volumes:

- `mariadb_data` mounted at `/var/lib/mysql`
- `wordpress_data` mounted at `/var/www/html`

Both are Docker named volumes configured to store their host data under:

```text
/home/sjoukni/data
```

This keeps the database and WordPress files available after container recreation.

## Service Notes

MariaDB:

- Initializes the datadir if needed.
- Creates the WordPress database and user.
- Sets the root password from a secret.
- Starts `mariadbd` as the foreground process.

WordPress:

- Waits for MariaDB.
- Downloads WordPress core if missing.
- Creates `wp-config.php` if missing.
- Installs WordPress only if it is not already installed.
- Creates the normal WordPress user if missing.
- Starts PHP-FPM in the foreground.

NGINX:

- Uses a self-signed certificate generated during image build.
- Enables only `TLSv1.2` and `TLSv1.3`.
- Forwards PHP requests to `wordpress:9000`.
- Exposes only port `443`.
