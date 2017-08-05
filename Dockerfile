FROM pensiero/apache-php-mysql

# Labels
LABEL maintainer "oscar.fanelli@gmail.com"

# Mysql packages
RUN apt update -q && apt install -yqq --force-yes \
    php-cli \
    php-gd \
    php-imagick \
    php-mcrypt \
    php-xml \
    php-xmlrpc \
    php-zip \
    postfix

# Start services
CMD ["/root/start.sh"]