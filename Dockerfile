FROM ubuntu:16.04 as base

# Cache your apt for quicker build on slow network
ARG USE_APT_CACHER_NG
COPY scripts/apt-cache.sh /usr/local/bin
RUN chmod +x /usr/local/bin/apt-cache.sh \
 && /usr/local/bin/apt-cache.sh

ENV DEBIAN_FRONTEND=noninteractive TERM=xterm

RUN apt-get update             \
 && apt-get install -y locales \
 && locale-gen en_US.UTF-8     \
 && dpkg-reconfigure locales

ENV LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Utilities
#RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync gettext-base

#Required
RUN apt-get install -y   \
            cron         \
            nginx        \
            php-fpm      \
            php-xml      \
            php-mbstring \
            php-mysql    \
            php-mcrypt   \
            php-intl     \
            php-zip      \
            php-imap     \
            php-curl     \
            php-gd       \
            php-bcmath   \
            sudo

COPY scripts/makeconfig.php /usr/local/share/mautic/scripts/makeconfig.php

# Install Runit
RUN apt-get install -y --no-install-recommends runit

FROM base AS build

RUN apt-get install -y \
            #composer  \
            wget       \
            unzip

#Mautic
RUN wget https://github.com/mautic/mautic/releases/download/2.14.2/2.14.2.zip
RUN unzip 2.14.2.zip -d /var/www/html \
 && rm -rf unzip 2.14.2.zip                                          \
 && cd /var/www/html                                                 \
 && chown -R www-data:www-data /var/www/html

FROM base AS final

COPY --from=build /var/www/html /var/www/html

#Put all Mautic instance config files into one directory    
RUN cd /var/www/html/app        \
 && mkdir -p local/cache/prod   \
             local/config       \
             local/themes       \
             local/idp          \
             local/media/files  \
             local/media/images \
             local/plugins
COPY config/paths_local.php /var/www/html/app/config/
COPY config/parameters_local.php /var/www/html/app/config/
RUN  chown -R www-data:www-data /var/www/html

RUN mkdir -p /var/log/mautic                                   \
 && touch /var/log/cron.pipe                                   \
 && chown www-data:www-data /var/log/mautic /var/log/cron.pipe

RUN mkdir -p /var/lib/mautic-default
COPY config/local.php /var/lib/mautic-default/local.php

COPY config/default /etc/nginx/sites-enabled/
COPY config/crontab /
COPY config/php.ini /etc/php/7.0/fpm/

# Output logs on stdout & stderr
RUN sed -i -e 's|error_log.*;|error_log /dev/stderr;|' /etc/nginx/nginx.conf \
 && sed -i -e 's|access_log.*;|access_log /dev/stdout;|' /etc/nginx/nginx.conf

# Add runit services
COPY scripts/sv /etc/service

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
#CMD bash -c 'export > /etc/envvars && /usr/sbin/runsvdir-start'
CMD /usr/local/bin/entrypoint.sh