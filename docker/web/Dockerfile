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
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN mv composer.phar /usr/bin/composer
RUN chmod +x /usr/bin/composer
RUN php -r "unlink('composer-setup.php');"

# bashrc
RUN echo "source /root/.bashrc.docker" >> /root/.bashrc
COPY .bashrc /root/.bashrc.docker

WORKDIR /var/www/prestation
CMD \
    /etc/init.d/php7.2-fpm start \
    && composer install \
    && nginx -g "daemon off;"
