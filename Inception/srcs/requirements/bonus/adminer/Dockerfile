FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends adminer php-cli php-mysql && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer && \
    find /usr/share -name adminer.php -exec cp {} /var/www/adminer/index.php \; -quit && \
    test -f /var/www/adminer/index.php

WORKDIR /var/www/adminer

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]
