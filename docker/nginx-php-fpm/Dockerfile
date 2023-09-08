FROM php:8.2.0-fpm-alpine

# Install packages
RUN apk add --no-cache curl git build-base zlib-dev oniguruma-dev autoconf bash
RUN apk add --update linux-headers

# Xdebug
ARG INSTALL_XDEBUG=false
RUN if [ ${INSTALL_XDEBUG} = true ]; \
    then \
      pecl install xdebug && docker-php-ext-enable xdebug; \
    fi;

COPY ./docker/nginx-php-fpm/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Postgres
RUN apk add --no-cache libpq-dev && docker-php-ext-install pdo_pgsql

# Nginx
RUN apk add --update --no-cache nginx
COPY ./docker/nginx-php-fpm/nginx.conf /etc/nginx/
COPY ./docker/nginx-php-fpm/run.sh /etc/nginx/
RUN chown -Rf www-data:www-data /var/lib/nginx

# Supervisor
RUN apk add --no-cache supervisor
COPY ./docker/nginx-php-fpm/supervisord.conf /etc/supervisord.conf

# Configure non-root user.
ARG PUID=1000
ARG PGID=1000
RUN apk --no-cache add shadow && \
    groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data

# Source code
RUN chown www-data:www-data /var/www
COPY --chown=www-data:www-data ./app /var/www
WORKDIR /var/www

# Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ARG BUILD_MODE=dev
RUN if [ ${BUILD_MODE} = dev ]; \
    then \
      composer install --no-interaction; \
    else \
      composer install --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader; \
    fi;
RUN chown -R www-data:www-data /var/www/vendor/

EXPOSE 8080

CMD ["/bin/sh", "/etc/nginx/run.sh"]


