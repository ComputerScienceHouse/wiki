FROM docker.io/mediawiki:1.46

COPY remoteip.conf /etc/apache2/mods-available/
RUN a2enmod remoteip

RUN apt-get update; \
    apt-get install -y wget unzip libldap-dev;

WORKDIR /tmp

# extension is spaghet and not available through composer
COPY download_git_extensions.sh .
RUN bash download_git_extensions.sh

WORKDIR /var/www/html

RUN chgrp -R 0 /var/www/html && \
    chmod -R g=u /var/www/html

COPY csh-wiki-logo.png images/

# Install composer, I guess...
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'c8b085408188070d5f52bcfe4ecfbee5f727afa458b2573b8eaaf77b3419b0bf2768dc67c86944da1544f06fa544fd47') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

RUN docker-php-ext-configure ldap && \
    docker-php-ext-install -j$(nproc) ldap && \
    mkdir /etc/ldap && \
    echo 'TLS_CACERT  /etc/ssl/certs/ca-certificates.crt' > /etc/ldap/ldap.conf 

COPY composer.local.json .
RUN composer update
