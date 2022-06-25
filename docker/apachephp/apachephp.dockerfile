FROM php:8.1-apache

RUN apt update && apt-get install -y \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libcurl4-openssl-dev \
    pkg-config \
    libssl-dev

COPY virtualhost.conf /etc/apache2/sites-available/virtualhost.conf
COPY apache2.conf /etc/apache2/apache2.conf
RUN pecl install -f xdebug && docker-php-ext-enable xdebug
COPY php.ini-development /usr/local/etc/php/php.ini
COPY xdebug.orig.ini /usr/local/etc/php/conf.d/xdebug.orig.ini
#RUN echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini
RUN cat /usr/local/etc/php/conf.d/xdebug.orig.ini >> /usr/local/etc/php/conf.d/docker-php-ext-debug.ini
RUN rm /usr/local/etc/php/conf.d/xdebug.orig.ini 
#RUN rm /usr/local/etc/php/conf.d/xdebug.ini

RUN apt clean && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install pdo pdo_mysql mysqli mbstring exif pcntl bcmath gd ctype fileinfo

RUN pecl install mongodb \
    &&  echo "extension=mongodb.so" > $PHP_INI_DIR/conf.d/mongo.ini


RUN a2enmod vhost_alias
RUN a2enmod rewrite
RUN a2enmod headers

RUN a2ensite virtualhost.conf

EXPOSE 80 9001
RUN useradd -G www-data,root --uid 1000 -d /home/userdev userdev
RUN mkdir -p /home/userdev/.composer && \
    chown -R userdev:userdev /home/userdev

