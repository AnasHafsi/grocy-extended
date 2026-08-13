# syntax=docker/dockerfile:1
#
# Three stages:
#   1. composer_build - installs PHP dependencies (composer.json -> ./packages)
#   2. yarn_build      - installs frontend dependencies (package.json -> ./public/packages,
#                         per .yarnrc's --modules-folder setting)
#   3. runtime image    - php:8.5-apache serving ./public, with the two
#                         dependency trees copied in from the stages above

########################################################################
# 1) PHP dependencies (Composer)
########################################################################
FROM php:8.5-cli AS composer_build
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN apt-get update && apt-get install -y --no-install-recommends \
        unzip git \
        libicu-dev libonig-dev \
        libpng-dev libjpeg62-turbo-dev libwebp-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype \
    && docker-php-ext-install -j"$(nproc)" gd intl mbstring \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-interaction --prefer-dist --optimize-autoloader

########################################################################
# 2) Frontend dependencies (Yarn)
########################################################################
FROM node:20-alpine AS yarn_build

RUN apk add --no-cache git

RUN corepack enable && corepack prepare yarn@1.22.22 --activate

WORKDIR /app
COPY .yarnrc package.json yarn.lock ./
RUN yarn install

########################################################################
# 3) Runtime image
########################################################################
FROM php:8.5-apache
RUN apt-get update && apt-get install -y --no-install-recommends \
        libsqlite3-dev libicu-dev libonig-dev zlib1g-dev \
        libpng-dev libjpeg62-turbo-dev libwebp-dev libfreetype6-dev \
        libldap2-dev \
    && docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype \
    && docker-php-ext-configure ldap --with-libdir=lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH) \
    && docker-php-ext-install -j"$(nproc)" pdo_sqlite gd intl mbstring ldap \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e "s!/var/www/html!\${APACHE_DOCUMENT_ROOT}!g" \
        /etc/apache2/sites-available/*.conf \
        /etc/apache2/apache2.conf \
        /etc/apache2/conf-available/*.conf

WORKDIR /var/www/html
COPY . .
COPY --from=composer_build /app/packages ./packages
COPY --from=yarn_build /app/public/packages ./public/packages

# Data lives outside the app tree so it survives image rebuilds/updates.
# GROCY_DATAPATH is read directly by public/index.php.
ENV GROCY_DATAPATH=/data
RUN mkdir -p /data \
    && chown -R www-data:www-data /var/www/html /data

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

VOLUME ["/data"]
EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]