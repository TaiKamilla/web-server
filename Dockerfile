ARG VARIANT=8.1-rc-apache-buster
# FROM mcr.microsoft.com/vscode/devcontainers/php:0-${VARIANT}
FROM php:${VARIANT}
LABEL org.opencontainers.image.source https://github.com/taikamilla/web-server


## envs
ENV INSTALL_DIR /var/www/html

# Developer tools
ENV TOOLS "htop screen vim nano sudo mlocate"

## Install software
RUN requirements="git-core curl wget build-essential openssl libssl-dev gnupg nodejs mariadb-client git cron libpng-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg62-turbo libjpeg62-turbo-dev libfreetype6-dev libicu-dev libpng-dev libxslt1-dev libzip-dev zip" \
    && apt-get update \
    && apt-get install -y $requirements $TOOLS\
    && apt-get update -yq

RUN curl -sS https://getcomposer.org/installer | php \
&& mv composer.phar /usr/local/bin/composer

# CMD [ "/bin/bash", "-c", "cron && apache2-foreground" ]
ENTRYPOINT [ "/bin/bash", "-c", "touch /var/www/html/test && cron && apache2-foreground" ]


