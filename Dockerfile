# from https://www.drupal.org/requirements/php#drupalversions
FROM php:8.2-apache as base

# Activate the rewrite_module
RUN set -ex; \
    \
    if command -v a2enmod; then \
      a2enmod rewrite; \
    fi; \
    \
    savedAptMark="$(apt-mark showmanual)";

RUN a2enmod rewrite

# Install packages
RUN apt-get update && apt-get install --no-install-recommends -y \
      libjpeg-dev \
      libpng-dev \
      libpq-dev \
      curl \
      wget \
      vim \
      git \
      unzip \
      libzip-dev \
      zip \
      default-mysql-client \
      # libsecret-1-dev \
    ;

# From the official docker image
RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
    docker-php-ext-install -j "$(nproc)" \
      gd \
      opcache \
      pdo_mysql \
      pdo_pgsql \
      zip \
    ;

# Clean repository
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html
WORKDIR /var/www/html

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer 

# COPY scan-apache.conf /etc/apache2/sites-enabled/000-default.conf

COPY package.json /var/www/html

FROM base as prod

# copy all files to /var/www/html
COPY . /var/www/html

FROM base as dev

# Node latest LTS
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -;
RUN apt-get update && apt-get install -y nodejs;

# Yarn
RUN npm install --global yarn
