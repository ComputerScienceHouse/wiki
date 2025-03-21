FROM docker.io/mediawiki:1.43

COPY remoteip.conf /etc/apache2/mods-available/
RUN a2enmod remoteip

RUN apt-get update; \
    apt-get install -y wget unzip libldap-dev;

WORKDIR /tmp

# extension is spaghet and not available through composer
COPY download_git_extensions.sh .
RUN bash download_git_extensions.sh

WORKDIR /var/www/html

COPY csh-wiki-logo.png images/

# Install composer, I guess...
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

RUN docker-php-ext-configure ldap && \
    docker-php-ext-install -j$(nproc) ldap && \
    mkdir /etc/ldap && \
    echo 'TLS_CACERT  /etc/ssl/certs/ca-certificates.crt' > /etc/ldap/ldap.conf

RUN chown -R www-data:www-data composer.json

# edwardspec/mediawiki-aws-s3 has old version of AWS SDK that causes problems
RUN composer require mediawiki/pluggable-auth jumbojett/openid-connect-php:0.9.10
COPY composer.local.json .
RUN composer update
