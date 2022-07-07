FROM docker.io/library/php:7.4-fpm

ARG VERSION
# https://github.com/mlocati/docker-php-extension-installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && \
    install-php-extensions mysqli zip gd intl xmlrpc soap \
                           opcache sockets imap xsl memcache \
                           redis exif pgsql && \
    rm /usr/local/bin/install-php-extensions

# Install binaries needed for moodle
RUN \
    apt-get update && \
    apt-get install -y unoconv ghostscript \
    texlive-lang-spanish texlive-latex-recommended texlive-latex-base \
    graphviz python3-minimal \
    imagemagick && \
    apt-get clean && \
    find /var/lib/apt/lists -type f -delete

# Install and generate locales
RUN \
    apt-get update && \
    apt-get install -y locales && \
    apt-get clean && \
    find /var/lib/apt/lists -type f -delete && \
    sed -i -e "s/# es/es/" /etc/locale.gen && \
    sed -i -e "s/# en/en/" /etc/locale.gen && \
    sed -i -e "s/# fr/fr/" /etc/locale.gen && \
    locale-gen

# Install usefool tools
RUN \
    apt-get update && \
    apt-get install -y unzip sudo mariadb-client figlet iputils-ping iproute2 telnet pwgen wget sudo procps grep && \
    apt-get clean && \
    find /var/lib/apt/lists -type f -delete

WORKDIR /var/www/html

COPY init.sh /moodle/
RUN chmod a+x /moodle/init.sh

ADD https://download.moodle.org/stable311/moodle-${VERSION}.tgz /moodle/moodle.tgz

CMD "/moodle/init.sh"
