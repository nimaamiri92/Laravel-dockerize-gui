FROM php:7.2.8-cli

LABEL maintainer="majid8911303@gmail"

ARG WWW_DATA_USER_ID

ENV PHP_REDIS_EXTENSION_VERSION 4.1.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    zlib1g-dev \
    cron \
    zip \
    unzip \
    supervisor \
    procps \
    gcc \
    musl-dev \
    autoconf \
    wget \
    git \
    libssl1.0-dev \
    libpng-dev \
    libxml2-dev \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql bcmath zip pcntl gd soap \
    && pecl install redis-4.1.1  \
    && docker-php-ext-enable redis \
    && pecl install mongodb \
    && echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/ext-mongodb.ini


# Installing composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer


# Install ffmpeg
RUN sed -i "s/jessie main/jessie main contrib non-free/" /etc/apt/sources.list \
&& echo "deb http://http.debian.net/debian jessie main contrib non-free" >> /etc/apt/sources.list \
&& apt-get update && apt-get install -y ffmpeg

RUN mkdir -p /var/log/supervisor /var/www/html

RUN cd /var/www/html/


## --------------------------------------------
## | Setup Crons
## --------------------------------------------

COPY ["./config/cron.d/", "/etc/cron.d/"]

# Give execution rights on the cron job
# Create the log file to be able to run tail
RUN chmod -R 0644 /etc/cron.d
RUN touch /var/log/cron.log
RUN chown -R www-data:www-data /var/log/cron.log



#COPY ./config/queue.conf /etc/supervisor/conf.d/queue.conf
COPY ./config/horizon.conf /etc/supervisor/conf.d/horizon.conf
#COPY ./config/schedule.conf /etc/supervisor/conf.d/schedule.conf
COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#COPY ./scripts/schedule.sh /usr/local/bin/schedule.sh
COPY ./scripts/run.sh /usr/local/bin/run.sh

RUN chmod +x /usr/local/bin/*.sh

RUN usermod -u ${WWW_DATA_USER_ID} www-data && \
    groupmod -g ${WWW_DATA_USER_ID} www-data && \
    chown -R www-data:www-data /var/www/ && \
    apt-get clean


EXPOSE 9001
WORKDIR /var/www/html
CMD ["/usr/local/bin/run.sh"]
