FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    bash \
    php8.2 \
    php8.2-cgi \
    php8.2-mysql \
    php8.2-fpm \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-cli \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/

RUN mkdir -p /run/php

COPY ./tools/wordpress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress.sh

ENTRYPOINT ["/usr/local/bin/wordpress.sh"]

WORKDIR /var/www/html/

EXPOSE 9000

CMD ["php-fpm8.2", "-F"]
