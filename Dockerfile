ARG VARIANT=8.1-rc-apache-buster
# FROM mcr.microsoft.com/vscode/devcontainers/php:0-${VARIANT}
FROM php:${VARIANT}
LABEL org.opencontainers.image.source https://github.com/taikamilla/web-server

## envs
ENV INSTALL_DIR /var/www/html

# Developer tools
ENV TOOLS "htop screen vim nano sudo mlocate"

## Install software
RUN requirements="git-core curl wget build-essential openssl libssl-dev gnupg nodejs mariadb-client git cron libonig-dev mcrypt libpng-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg62-turbo libjpeg62-turbo-dev libfreetype6-dev libicu-dev libpng-dev libxslt1-dev libzip-dev zip" \

    && apt-get update \
    && apt-get install -y $requirements $TOOLS\
    && apt-get update -yq

# Install composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Install REDIS
RUN wget http://download.redis.io/redis-stable.tar.gz \
    && tar xvzf redis-stable.tar.gz \
    && cd redis-stable \
    && make \
    && make install

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

EXPOSE 80

# CMD [ "/bin/bash", "-c", "cron && apache2-foreground" ]
ENTRYPOINT [ "/bin/bash", "-c", "cron && apache2-foreground" ]


