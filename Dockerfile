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
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
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
