FROM docker.io/library/php:8.0-fpm

ARG VERSION

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,id=aptcache,target=/var/cache/apt \
    --mount=type=cache,id=aptlib,target=/var/lib/apt \
    apt-get update && \
    apt-get install -y apt-utils

# https://github.com/mlocati/docker-php-extension-installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN --mount=type=cache,id=aptcache,target=/var/cache/apt \
    --mount=type=cache,id=aptlib,target=/var/lib/apt \
    chmod a+x /usr/local/bin/install-php-extensions && \
    install-php-extensions mysqli zip gd intl xmlrpc soap \
    opcache sockets imap xsl memcache \
    redis exif pgsql

# Install binaries needed for moodle
RUN --mount=type=cache,id=aptcache,target=/var/cache/apt \
    --mount=type=cache,id=aptlib,target=/var/lib/apt \
    apt-get update && \
    apt-get install -y unoconv ghostscript \
    texlive-lang-spanish texlive-latex-recommended texlive-latex-base \
    graphviz python3-minimal \
    imagemagick

# Install and generate locales
RUN --mount=type=cache,id=aptcache,target=/var/cache/apt \
    --mount=type=cache,id=aptlib,target=/var/lib/apt \
    apt-get update && \
    apt-get install -y locales && \
    sed -i -e "s/# es/es/" /etc/locale.gen && \
    sed -i -e "s/# en/en/" /etc/locale.gen && \
    sed -i -e "s/# fr/fr/" /etc/locale.gen && \
    locale-gen

# Install usefool tools
RUN --mount=type=cache,id=aptcache,target=/var/cache/apt,rw \
    --mount=type=cache,id=aptlib,target=/var/lib/apt \
    apt-get update && \
    apt-get install -y unzip sudo mariadb-client figlet iputils-ping iproute2 telnet pwgen wget sudo procps grep 

ADD moosh.tar /
RUN echo "#!/bin/bash" > /usr/bin/moosh && \
    echo '/moosh/moosh.php -p /var/www/html/moodle -n $@' >> /usr/bin/moosh && \
    chmod a+x /usr/bin/moosh

WORKDIR /var/www/html

COPY init.sh /moodle/
RUN chmod a+x /moodle/init.sh
COPY cron.sh /moodle/
RUN chmod a+x /moodle/cron.sh

ADD https://download.moodle.org/stable311/moodle-${VERSION}.tgz /moodle/moodle.tgz

CMD "/moodle/init.sh"






