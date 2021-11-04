ARG VARIANT=8.1-rc-apache-buster
# FROM mcr.microsoft.com/vscode/devcontainers/php:0-${VARIANT}
FROM php:${VARIANT}
LABEL org.opencontainers.image.source https://github.com/taikamilla/web-server

## envs
ENV INSTALL_DIR /var/www/html

# Developer tools
ENV TOOLS "htop screen vim nano sudo mlocate"

## Install software
RUN requirements="git-core npm curl wget build-essential openssl libssl-dev gnupg mariadb-client git cron libonig-dev mcrypt libpng-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg62-turbo libjpeg62-turbo-dev libfreetype6-dev libicu-dev libpng-dev libxslt1-dev libzip-dev zip" \
    && apt-get update \
    && apt-get install -y $requirements $TOOLS\
    && apt-get update -yq

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_17.x | bash \
    && apt-get install nodejs -yq 

# Install composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Install REDIS
RUN wget http://download.redis.io/redis-stable.tar.gz \
    && tar xvzf redis-stable.tar.gz \
    && cd redis-stable \
    && make \
    && make install

# Configure libraries
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/

# Install libraries
RUN libraries_to_install="bcmath gd intl mbstring mysqli opcache pdo_mysql soap xsl zip" \
    && docker-php-ext-install $libraries_to_install

# Clean repositories cache
RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /tmp/pear \
    && rm -Rf redis-stable redis-stable.tar.gz

# Turn on mod_rewrite
RUN a2enmod rewrite proxy_fcgi setenvif

# Set PHP configuration
RUN echo "memory_limit=4096M" > /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo 'max_execution_time = 3600' >> /usr/local/etc/php/conf.d/docker-php-maxexectime.ini \
    && echo 'upload_max_filesize = 1024M' >> /usr/local/etc/php/conf.d/docker-php-uploadmaxfilesize.ini \
    && echo 'opcache.validate_root = 1' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

EXPOSE 80

# CMD [ "/bin/bash", "-c", "cron && apache2-foreground" ]
ENTRYPOINT [ "/bin/bash", "-c", "cron && apache2-foreground" ]


