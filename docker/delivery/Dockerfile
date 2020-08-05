FROM php:7.4-cli-buster

RUN \
    apt-get update \
    && apt-get install -y zlib1g-dev libicu-dev g++ git libzip-dev zip unzip \
    && docker-php-ext-install intl mysqli zip \
    && mkdir ~/.ssh/ \
    && ssh-keyscan -H github.com >> ~/.ssh/known_hosts \
    && ssh-keyscan -H sephidev.net >> ~/.ssh/known_hosts

ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

COPY ssh/github /root/.ssh/github
COPY ssh/server_site /root/.ssh/server_site

RUN \
    chmod 400 ~/.ssh/github \
    && chmod 400 ~/.ssh/server_site \
    && echo "Host github.com" > ~/.ssh/config \
    && echo "  IdentityFile ~/.ssh/github" >> ~/.ssh/config \
    && echo "Host sephidev.net" >> ~/.ssh/config \
    && echo "  IdentityFile ~/.ssh/server_site" >> ~/.ssh/config \
    && ln -snf /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && echo "Europe/Paris" > /etc/timezone

COPY site.sh /app/site.sh
