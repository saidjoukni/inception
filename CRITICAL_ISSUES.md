# Critical Issues Report

Project reviewed: `Inception/`

Date: 2026-06-11

This review is based on static inspection plus non-mutating validation commands. No project files were changed while analyzing the project.

## 1. The required `Makefile` is empty

**Severity:** Critical

**Evidence:**

- `Inception/Makefile` is a tracked file with `0` bytes.
- Running `make -n` inside `Inception/` fails with:

```text
make: *** No targets.  Stop.
```

**Impact:**

The project cannot be built, started, stopped, cleaned, or reset through the expected project interface. For an Inception submission this is a direct delivery blocker because the evaluator normally expects targets such as `all`, `up`, `down`, `clean`, `fclean`, and `re`.

**Recommended fix:**

Implement the required Makefile targets and make sure they:

- create `/home/sjoukni/data/mariadb` and `/home/sjoukni/data/wordpress` when needed;
- run `docker compose -f srcs/docker-compose.yml up --build -d`;
- stop and remove the stack cleanly;
- clean Docker volumes and host data only in explicit cleanup targets.

## 2. Credentials are committed in `.env`, while secret files are empty and unused

**Severity:** Critical

**Evidence:**

- `Inception/srcs/.env` is tracked by Git and contains database and WordPress passwords.
- `Inception/secrets/credentials.txt`, `Inception/secrets/db_password.txt`, and `Inception/secrets/db_root_password.txt` are tracked but empty.
- `Inception/srcs/docker-compose.yml` uses `env_file: .env`, but does not define Compose `secrets:`.
- No code references `_FILE`, `credentials.txt`, `db_password.txt`, or `db_root_password.txt`.

**Impact:**

This defeats the purpose of the `secrets/` directory and exposes credentials directly in the repository. It is also likely to violate the project rule that credentials must not be hardcoded in source-controlled files.

**Recommended fix:**

Use a safe secret-loading pattern consistently:

- keep real secret values out of Git;
- commit only an example file such as `.env.example`;
- either use Docker Compose secrets or load passwords from files mounted into containers;
- make the setup scripts read the secret files instead of raw committed literals.

## 3. MariaDB root password is never actually configured

**Severity:** Critical

**Evidence:**

`Inception/srcs/requirements/mariadb/tools/setup.sh` uses `MYSQL_ROOT_PASSWORD` only when flushing privileges and shutting down MariaDB:

```sh
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
```

There is no command that sets or alters the MariaDB root password.

**Impact:**

The configured root password may not match the actual MariaDB root account. Depending on MariaDB's default authentication state, the shutdown/flush commands may fail, while the script continues anyway because it does not use `set -e`. This can leave the database initialized with unexpected root authentication and can also cause startup instability.

**Recommended fix:**

During first-time database initialization:

- explicitly set the root password;
- create the WordPress database and user only after validating required variables;
- fail immediately on SQL/setup errors;
- make the script idempotent by using a clear initialization marker or checking the database state.

## 4. MariaDB startup script ignores failures and can continue after broken initialization

**Severity:** Critical

**Evidence:**

`Inception/srcs/requirements/mariadb/tools/setup.sh` has no strict shell mode and does not check command failures:

```sh
service mariadb start
sleep 3
mysql -e "CREATE DATABASE IF NOT EXISTS ..."
mysql -e "GRANT ALL PRIVILEGES ..."
mysqladmin ... shutdown
exec mysqld_safe
```

**Impact:**

If MariaDB fails to start, credentials are wrong, SQL fails, or shutdown fails, the script still reaches `exec mysqld_safe`. That can produce a container that looks started but has no valid database/user setup, or a second MariaDB launch attempt while the first daemon is still running.

**Recommended fix:**

Add robust startup behavior:

- `set -eu` or equivalent error handling;
- wait for MariaDB with an actual readiness loop instead of fixed `sleep 3`;
- validate all required environment/secrets before running SQL;
- stop immediately if any SQL command fails;
- use `exec mariadbd`/`mysqld` as the final foreground process only after successful initialization.

## 5. NGINX configuration breaks normal WordPress routing

**Severity:** Critical

**Evidence:**

`Inception/srcs/requirements/nginx/conf/nginx.conf` uses:

```nginx
location / {
    try_files $uri $uri/ =404;
}
```

**Impact:**

WordPress relies on front-controller routing through `index.php`. With the current `try_files`, normal WordPress permalinks and many non-file routes return `404` instead of being passed to WordPress.

**Recommended fix:**

Route missing paths to WordPress:

```nginx
location / {
    try_files $uri $uri/ /index.php?$args;
}
```

## 6. WordPress initialization can leave a permanently half-installed volume

**Severity:** Critical

**Evidence:**

`Inception/srcs/requirements/wordpress/tools/setup.sh` skips all setup when `wp-config.php` exists:

```sh
if [ ! -f "wp-config.php" ]; then
    wp core download --allow-root
    wp config create ...
    wp core install ...
    wp user create ...
fi
```

**Impact:**

If the script fails after creating `wp-config.php` but before `wp core install` or user creation, future container starts skip setup entirely. The WordPress volume can remain in a broken partial state until manually deleted.

**Recommended fix:**

Check actual installation state instead of only checking for `wp-config.php`, for example with `wp core is-installed`. If the config exists but WordPress is not installed, continue the missing install steps or fail with a clear error.

## Additional High-Risk Notes

- `docker compose config --quiet` succeeds, but Compose warns that `version: '3'` is obsolete.
- `Inception/srcs/docker-compose.yml` hardcodes host paths under `/home/sjoukni/data`. This may be acceptable for this login, but the missing Makefile means the project cannot reliably create or reset those paths.
- `Inception/srcs/requirements/nginx/.dockerignore` is empty, unlike the MariaDB and WordPress contexts.
- Live container status could not be checked because access to `/var/run/docker.sock` was denied in the current environment.
