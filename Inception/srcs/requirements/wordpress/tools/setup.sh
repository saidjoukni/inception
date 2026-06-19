#!/bin/bash
set -eu

cd /var/www/html

read_secret() {
    if [ ! -f "$1" ]; then
        echo "Missing secret file: $1" >&2
        exit 1
    fi
    tr -d '\r\n' < "$1"
}

MYSQL_PASSWORD="$(read_secret "${MYSQL_PASSWORD_FILE:-/run/secrets/db_password}")"

if [ ! -f "${WP_CREDENTIALS_FILE:-/run/secrets/credentials}" ]; then
    echo "Missing WordPress credentials secret" >&2
    exit 1
fi

set -a
. "${WP_CREDENTIALS_FILE:-/run/secrets/credentials}"
set +a

if [ -z "${MYSQL_DATABASE:-}" ] || [ -z "${MYSQL_USER:-}" ] || [ -z "$MYSQL_PASSWORD" ] || \
   [ -z "${DOMAIN_NAME:-}" ] || [ -z "${WP_ADMIN_USER:-}" ] || [ -z "${WP_ADMIN_PASSWORD:-}" ] || \
   [ -z "${WP_ADMIN_EMAIL:-}" ] || [ -z "${WP_USER:-}" ] || [ -z "${WP_USER_PASSWORD:-}" ] || \
   [ -z "${WP_USER_EMAIL:-}" ]; then
    echo "WordPress configuration is incomplete" >&2
    exit 1
fi

echo "Waiting for MariaDB to start..."
db_ready=0
for _ in $(seq 1 60); do
    if mysqladmin ping -h"mariadb" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; then
        db_ready=1
        break
    fi
    sleep 2
done

if [ "$db_ready" -ne 1 ]; then
    echo "MariaDB did not become ready for WordPress" >&2
    exit 1
fi

if [ ! -f "wp-load.php" ] || [ ! -f "wp-includes/version.php" ]; then
    wp core download --allow-root --force
fi

if [ ! -f "wp-config.php" ]; then
    wp config create --dbname=$MYSQL_DATABASE \
                     --dbuser=$MYSQL_USER \
                     --dbpass=$MYSQL_PASSWORD \
                     --dbhost=mariadb \
                     --allow-root
fi

if ! wp core is-installed --allow-root >/dev/null 2>&1; then
    wp core install --url="https://$DOMAIN_NAME" \
                    --title="${WP_TITLE:-Inception}" \
                    --admin_user=$WP_ADMIN_USER \
                    --admin_password=$WP_ADMIN_PASSWORD \
                    --admin_email=$WP_ADMIN_EMAIL \
                    --skip-email \
                    --allow-root
fi

if ! wp user get "$WP_USER" --allow-root >/dev/null 2>&1; then
    wp user create $WP_USER $WP_USER_EMAIL \
                   --role=author \
                   --user_pass=$WP_USER_PASSWORD \
                   --allow-root
fi

if ! wp plugin is-active redis-cache --allow-root >/dev/null 2>&1; then
# Check if the Redis plugin is already installed and active. If not, proceed with the setup.

    wp config set WP_REDIS_HOST redis --allow-root
    # Inject the Redis hostname into wp-config.php. 'redis' refers to our container name in docker-compose.yml.

    wp config set WP_REDIS_PORT 6379 --raw --allow-root
    # Specify the port Redis is listening on. '--raw' ensures it's written as an integer, not a string.

    wp plugin install redis-cache --activate --allow-root
    # Download the Redis Object Cache plugin from the WordPress repository and activate it immediately.

    wp redis enable --allow-root
    # Trigger the plugin's internal script to enable object caching and connect to the Redis server.
fi

chown -R www-data:www-data /var/www/html

exec /usr/sbin/php-fpm8.2 -F
