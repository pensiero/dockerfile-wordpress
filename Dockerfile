# pensiero/wordpress, PHP 8.4 line.
#
# Built on the official php:8.4-apache image (Debian 13, Apache 2.4, mod_php)
# instead of the old ubuntu:18.04 + ondrej PPA chain (apache-php ->
# apache-php-mysql -> wordpress), which could no longer be patched. The site
# layout stays the same: the code lives in /var/www/public, .htaccess works,
# and the PHP settings are the ones the sites already ran with, plus the
# hardening from the PHP security advisory of 2026-10-21.
#
# Build for the cluster (x86_64) from an Apple silicon laptop:
#   docker buildx build --platform linux/amd64 -t pensiero/wordpress:php8.4-YYYYMMDD --push .
# Never overwrite a tag: the charts run with imagePullPolicy IfNotPresent.
FROM php:8.4.27-apache-trixie

LABEL maintainer="oscar.fanelli@gmail.com"

# Extensions the php7.4 image had and WordPress or its plugins use. Built with
# the official images' recipe: install the -dev packages, compile, then keep
# only the runtime libraries the compiled extensions link against.
# FFI is left out on purpose: no site needs it and it lets PHP load arbitrary
# native code.
RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libavif-dev \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libmagickwand-dev \
        libpng-dev \
        libwebp-dev \
        libxslt1-dev \
        libzip-dev \
    ; \
    docker-php-ext-configure gd --with-avif --with-freetype --with-jpeg --with-webp; \
    docker-php-ext-install -j "$(nproc)" \
        bcmath calendar exif ftp gd gettext intl mysqli pcntl pdo_mysql \
        shmop sockets sysvmsg sysvsem sysvshm xsl zip \
    ; \
    pecl install imagick-3.8.0; \
    docker-php-ext-enable imagick; \
    rm -r /tmp/pear; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    extdir="$(php -r 'echo ini_get("extension_dir");')"; \
    ldd "$extdir"/*.so \
        | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*; \
    ! { ldd "$extdir"/*.so | grep 'not found'; }; \
    err="$(php --version 3>&1 1>&2 2>&3)"; \
    [ -z "$err" ]

# Every setting a chart may need to change is an environment variable, so a
# chart sizes the image to its own memory limit without mounting config files.
# APACHE_MAX_REQUEST_WORKERS: a WordPress worker takes 60-110 MB, so keep
# workers x ~100 MB under the container's memory limit. The old image allowed
# 150, which is how gamempire was OOM-killed on 2026-10-22.
ENV PROJECT_PATH=/var/www \
    PROJECT_PUBLIC_DIR=public \
    APACHE_MAX_REQUEST_WORKERS=10 \
    PHP_MEMORY_LIMIT=256M \
    PHP_POST_MAX_SIZE=32M \
    PHP_UPLOAD_MAX_FILESIZE=16M

# PHP: production defaults, then our settings on top.
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY config/php.ini "$PHP_INI_DIR/conf.d/zz-pensiero.ini"

# Apache: the same virtual host as before (document root /var/www/public,
# .htaccess allowed), the modules WordPress permalinks and caching headers use,
# a prefork pool sized by environment, and less said about the server.
COPY config/apache-virtualhost.conf /etc/apache2/sites-available/000-default.conf
COPY config/mpm_prefork.conf /etc/apache2/mods-available/mpm_prefork.conf
COPY config/apache-hardening.conf /etc/apache2/conf-available/zz-pensiero.conf
RUN set -eux; \
    a2enmod rewrite expires headers; \
    a2enconf zz-pensiero

# No mail server in the image. The old one ran postfix for PHP mail(), and
# nothing showed mail ever left a Hetzner IP that way. Sites that send mail use
# an SMTP plugin (WP Mail SMTP) with a real provider.

WORKDIR /var/www

# apache2-foreground (from the base image) stays the command.
