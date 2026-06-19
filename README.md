*This project has been created as part of the 42 curriculum by sjoukni.*

# Inception

## Description

Inception is a small Docker Compose infrastructure for running a WordPress website behind an HTTPS-only NGINX entrypoint.

The mandatory stack contains three custom-built services:

- `nginx`: serves HTTPS traffic on port `443` only and forwards PHP requests to WordPress.
- `wordpress`: runs WordPress with PHP-FPM only, without NGINX.
- `mariadb`: stores the WordPress database only, without NGINX.

All images are built from local Dockerfiles based on `debian:bookworm`, the penultimate stable Debian release as of this project update. No ready-made WordPress, MariaDB, or NGINX application images are used.

The source files are in `Inception/srcs`, the Makefile is in `Inception/`, and secrets are read from `Inception/secrets`.

## Project Description

Docker is used to isolate each service in its own container while still allowing them to communicate through a private Docker network. Docker Compose describes the full infrastructure in one file, including services, volumes, secrets, and networking.

Main design choices:

- NGINX is the only public entrypoint and exposes only `443:443`.
- TLS is limited to `TLSv1.2` and `TLSv1.3`.
- WordPress files persist in the `wordpress_data` named volume.
- MariaDB files persist in the `mariadb_data` named volume.
- Both named volumes store their host data under `/home/sjoukni/data`.
- Passwords are loaded through Docker secrets instead of being written directly in Dockerfiles.

Virtual Machines vs Docker:

- A virtual machine runs a full guest operating system with its own kernel.
- Docker containers share the host kernel and isolate only the application filesystem, process space, and network.
- For this project, Docker is lighter and makes one-service-per-container infrastructure easier to reproduce.

Secrets vs Environment Variables:

- Environment variables are useful for non-sensitive configuration such as domain names, database names, and usernames.
- Secrets are better for passwords because they are mounted as files under `/run/secrets` and are not baked into Docker images.

Docker Network vs Host Network:

- A Docker bridge network gives containers private DNS names such as `mariadb` and `wordpress`.
- Host networking would expose services directly on the host and is forbidden by the subject.

Docker Volumes vs Bind Mounts:

- Docker named volumes are managed by Docker and survive container deletion.
- Bind mounts directly expose an arbitrary host path to a container.
- This project uses named volumes configured to store data under `/home/sjoukni/data`, as required by the subject.

## Instructions

Add the local domain to `/etc/hosts` on the VM:

```text
127.0.0.1 sjoukni.42.fr
```

Start the stack:

```sh
cd Inception
make
```

Useful commands:

```sh
make ps       # show services
make logs     # follow service logs
make down     # stop and remove containers
make clean    # stop and remove containers/orphans
make fclean   # remove containers, Docker volumes, and /home/sjoukni/data
make re       # full clean rebuild
```

Access the website:

```text
https://sjoukni.42.fr
```

The WordPress admin panel is available at:

```text
https://sjoukni.42.fr/wp-admin
```

## Resources

- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- Docker secrets documentation: https://docs.docker.com/compose/how-tos/use-secrets/
- NGINX documentation: https://nginx.org/en/docs/
- WordPress CLI documentation: https://developer.wordpress.org/cli/commands/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/

AI was used as a review and implementation assistant to compare the local project against the subject, identify missing mandatory requirements, improve startup scripts, and draft documentation. The final files were reviewed and validated with local static checks.
