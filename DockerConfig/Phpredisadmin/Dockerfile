FROM php:7.2.8-apache

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
  git

# Installing composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

RUN git clone https://github.com/erikdubbelboer/phpRedisAdmin.git \
&& mv ./phpRedisAdmin/* . \
&& rm -rf phpRedisAdmin \
&& composer install \
&& cp includes/config.environment.inc.php includes/config.inc.php

COPY config.php /var/www/html/includes/config.inc.php

EXPOSE 80
