# create a container as "deploy" replacement
# it's a container to build the web app without changing the host
# "containerize all the things"

FROM debian:stretch-slim
MAINTAINER Hans-Peter Buniat <hans-peter.buniat@invia.de>

# php
ENV DEBIAN_FRONTEND noninteractive
ENV NODE_VERSION 8.11.3
ENV NPM_VERSION 5.6.0
ENV COMPOSER_VERSION 1.6.5

RUN mkdir -p /var/www/projects/flight-ibe && \
    chown -R www-data:www-data /var/www/projects

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget \
        ca-certificates \
        apt-transport-https \
        gnupg \
        git

COPY sources.list /etc/apt/sources.list.d/invia.list
RUN wget https://packages.sury.org/php/apt.gpg && \
    apt-key add apt.gpg && \
    wget https://s3-eu-west-1.amazonaws.com/tideways/packages/EEB5E8F4.gpg && \
    apt-key add EEB5E8F4.gpg && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y --force-yes \
        make \
        curl \
        mc \
        openssl \
        nano \
        filter \
        php7.2-apcu \
        php7.2-cli \
        php7.2-common \
        php7.2-curl \
        php7.2-dev \
        php7.2-gd \
        php7.2-igbinary \
        php7.2-imagick \
        php7.2-intl \
        php7.2-json \
        php7.2-ldap \
        php7.2-mbstring \
        php7.2-memcached \
        php7.2-mongo \
        php7.2-mysqlnd \
        php7.2-opcache \
        php7.2-soap \
        php7.2-sqlite \
        php7.2-xml \
        php7.2-xdebug \
        php-ssh2 \
        openssh-server \
        openssh-client \
        supervisor \
        locales \
        tideways-daemon \
        tideways-php \
        tideways-cli \
        apt-utils \
        autoconf \
        automake \
        bzip2 \
        file \
        make \
        mysql-client \
        patch \
        xz-utils \
        zlib1g-dev \
        rsync \
        subversion \
        sudo \
        unzip \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN set -ex \
      && for key in \
        9554F04D7259F04124DE6B476D5A82AC7E37093B \
        94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
        0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
        FD3A5288F042B6850C66B31F09FE44734EB7990E \
        71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
        DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
        B9AE9905FFD7803F25714661B63B535A4C206CA9 \
        C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      ; do \
        gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
      done

# install specified composer, node, npm node-gyp and yarn
# && fix broken npm installation after npm installation (missing /usr/local/lib/node_modules/npm/node_modules) ...
RUN rm -rf /usr/local/bin/npm \
    && rm -rf /usr/local/lib/node_modules \
    && rm -rf ~/.npm \
  && curl -sSLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -sSLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
    && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
  && curl -sS "https://dl.yarnpkg.com/debian/pubkey.gpg" | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qqy \
    && apt-get install --no-install-recommends -qqy --force-yes yarn \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && npm install -g bower node-gyp npm@$NPM_VERSION \
#  && cd /usr/local/lib/node_modules/npm \
#    && yarn install \
  && curl -sS --insecure -o /usr/local/bin/composer https://getcomposer.org/download/$COMPOSER_VERSION/composer.phar \
    && chmod +x /usr/local/bin/composer

# copy build script
ADD build.sh /usr/local/bin/build-application
RUN chmod +x /usr/local/bin/build-application

ADD entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set up the application directory
VOLUME ["/app"]
WORKDIR /app

# Set up the command arguments
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD build-application