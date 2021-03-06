## dockerfile-wordpress

Docker image acting as the perfect base for wordpress.

It doesn't contain a Wordpress application, just all the services that Wordpress needs.

### How to use it
Use as image tag `pensiero/wordpress`.

### Services included

- Apache
- PHP 7.4
- Postfix

### Available PHP versions
Check out all the available tags on [Docker Hub](https://hub.docker.com/repository/docker/pensiero/wordpress/tags).

If you wanna use a different php version, you can leverage any of the following images:
- `PHP 5.6` --> `pensiero/wordpress:php5.6`
- `PHP 7.0` --> `pensiero/wordpress:php7.0`
- `PHP 7.2` --> `pensiero/wordpress:php7.2`
- `PHP 7.4` --> `pensiero/wordpress:php7.4`

### PHP extensions included

- `php-bcmath`
- `php-cli`
- `php-common` (with PHP7 core)
- `php-curl`
- `php-dom`
- `php-exif` (with PHP7 core)
- `php-gd`
- `php-imagick`
- `php-json` (with PHP7 core)
- `php-mbstring`
- `php-mcrypt`
- `php-mysql`
- `php-opcache` (with PHP7 core)
- `php-openssl` (with PHP7 core)
- `php-readline` (with PHP7 core)
- `php-intl`
- `php-xml`
- `php-xmlrpc`
- `php-zip`

Check all the installed php extensions with: `dpkg -l | grep php`