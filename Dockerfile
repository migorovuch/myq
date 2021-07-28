FROM mysql AS mysql

CMD "--default-authentication-plugin=mysql_native_password"

FROM php:8-fpm AS php

#install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get update \
    && apt-get install -y libbz2-dev libpq-dev libzip-dev libxml2-dev zip unzip librabbitmq-dev git
RUN docker-php-ext-install \
    pdo_mysql mysqli opcache bcmath sockets zip bz2

COPY /var/www/project/myq_back/docker/php-fpm/symfony.ini /usr/local/etc/php/conf.d
COPY /var/www/project/myq_back/docker/php-fpm/symfony.ini /usr/local/etc/php/cli/conf.d
COPY /var/www/project/myq_back/docker/php-fpm/symfony.pool.conf /usr/local/etc/php/php-fpm.d/

WORKDIR /var/www/project

FROM nginx AS nginx

COPY /var/www/project/myq_back/docker/nginx/nginx.conf /etc/nginx/
COPY /var/www/project/myq_back/docker/nginx/symfony.conf /etc/nginx/conf.d/

RUN echo "upstream php-upstream { server php:9000; }" > /etc/nginx/conf.d/upstream.conf

RUN adduser -D -g '' -G www-data www-data

CMD ["nginx"]

EXPOSE 80
EXPOSE 443

FROM node:12 AS node

WORKDIR /var/www/project/myq_front/public/front

RUN npm install -g @vue/cli

