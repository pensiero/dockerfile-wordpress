### dockerfile-wordpress

Docker image acting as the perfect base for wordpress.

It doesn't contain a Wordpress application, just all the services that Wordpress needs.

#### Services included

- Apache
- PHP
- Postfix

#### PHP extensions included

- php-bcmath
- php-cli
- php-common (with PHP7 core)
- php-curl
- php-dom
- php-exif (with PHP7 core)
- php-gd
- php-imagick
- php-json (with PHP7 core)
- php-mbstring
- php-mcrypt
- php-mysql
- php-opcache (with PHP7 core)
- php-openssl (with PHP7 core)
- php-readline (with PHP7 core)
- php-intl
- php-xml
- php-xmlrpc
- php-zip


See all the installed php extensions with: `dpkg -l | grep php`