FROM ubuntu:18.04

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y vim zip

# nginx
RUN apt-get install -y nginx
COPY vhost.conf /etc/nginx/sites-enabled/adopteunchiot.conf

# php
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y php7.2-fpm php7.2-zip

# composer
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# bashrc
RUN echo "source /root/.bashrc.docker" >> /root/.bashrc
COPY .bashrc /root/.bashrc.docker

WORKDIR /var/www/prestation
CMD \
    /etc/init.d/php7.2-fpm start \
    && composer install \
    && nginx -g "daemon off;"
