# choosing Debian bookworm as the mandatory penultimate stable base image
FROM debian:bookworm

# update apt and install WordPress runtime dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends ca-certificates wget php8.2-cli php8.2-fpm php8.2-mysql mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# 3. Download WP-CLI and make it executable
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# 4. Create the run directory for PHP-FPM (CRITICAL to prevent crashes)
RUN mkdir -p /run/php

# 5. Copy the config file (to change listen to 9000)
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# 6. Copy the setup script
COPY tools/setup.sh /

# 7. Make the script executable
RUN chmod +x /setup.sh

# 8. Start the script
CMD ["bash", "/setup.sh"]
