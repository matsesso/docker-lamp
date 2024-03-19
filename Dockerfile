# Utilizaremos Ubuntu como SO
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Update do linux e instalação de dependências 
RUN apt-get update && apt-get install -y
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:ondrej/php

# Instalação do Apache, PHP, plugins do PHP e softwares necessários
RUN apt-get install -y build-essential \
    nano \
    unzip \
    curl \
    locales \
    apache2 \
    php8.1 \
    php8.1-common \
    php8.1-mysql \
    php8.1-xml \
    php8.1-xmlrpc \
    php8.1-curl \
    php8.1-gd \
    php8.1-imagick \
    php8.1-cli \
    php8.1-dev \
    php8.1-imap \
    php8.1-mbstring \
    php8.1-opcache \
    php8.1-soap \
    php8.1-zip \
    php8.1-intl \
    php8.1-bcmath \
    php8.1-pgsql \
    php8.1-pspell \
    libapache2-mod-php8.1 \
    && apt-get clean 

RUN locale-gen pt_BR.UTF-8

# Instala o Composer para o PHP
RUN cd /usr/local/lib/ && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Instala o CA Certificates para futura configuração SSL
RUN apt-get install --reinstall ca-certificates -y

# Cria a pasta src, que é a pasta onde ficará sua aplicação
ADD src/ /var/www/html/src

# Seta as permissões da pasta src
RUN chown $USER:www-data -R /var/www/html/src
RUN chmod u=rwX,g=srX,o=rX -R /var/www/html/src
RUN find /var/www/html/src -type d -exec chmod g=rwxs "{}" \;
RUN find /var/www/html/src -type f -exec chmod g=rws "{}" \;

# Ativa Apache mod_rewrite
RUN a2enmod rewrite
RUN a2enmod actions

# Altera AllowOverride de None para All
RUN sed -i '170,174 s/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Inicia o Apache
RUN service apache2 restart

# Expõe as portas necessárias
EXPOSE 80 8080 3306

# Roda o apache fulltime
ENTRYPOINT ["apache2ctl", "-D", "FOREGROUND"]