FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:ondrej/php

RUN apt-get install -y build-essential \
    nano \
    unzip \
    curl \
    locales \
    apache2 \
    php8.3 \
    php8.3-common \
    php8.3-mysql \
    php8.3-xml \
    php8.3-xmlrpc \
    php8.3-curl \
    php8.3-gd \
    php8.3-imagick \
    php8.3-cli \
    php8.3-dev \
    php8.3-imap \
    php8.3-mbstring \
    php8.3-opcache \
    php8.3-soap \
    php8.3-zip \
    php8.3-intl \
    php8.3-bcmath \
    php8.3-pgsql \
    php8.3-pspell \
    libapache2-mod-php8.3 \
    && apt-get clean 

RUN locale-gen pt_BR.UTF-8

RUN cd /usr/local/lib/ && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

RUN apt-get install --reinstall ca-certificates -y

# pasta src
ADD src/ /var/www/html/src

# permissões da pasta src
RUN chown $USER:www-data -R /var/www/html/src
RUN chmod u=rwX,g=srX,o=rX -R /var/www/html/src
RUN find /var/www/html/src -type d -exec chmod g=rwxs "{}" \;
RUN find /var/www/html/src -type f -exec chmod g=rws "{}" \;

# apache mod_rewrite
RUN a2enmod rewrite
RUN a2enmod actions

# Altera AllowOverride de None para All
RUN sed -i '170,174 s/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# inicia o Apache
RUN service apache2 restart

# portas necessárias
EXPOSE 80 8080 3306

ENTRYPOINT ["apache2ctl", "-D", "FOREGROUND"]