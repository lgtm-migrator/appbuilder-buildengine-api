FROM silintl/php-web:latest
MAINTAINER Phillip Shipley <phillip_shipley@sil.org>

ENV REFRESHED_AT 2015-05-26

COPY build/example.conf /etc/apache2/sites-enabled/

RUN mkdir -p /data
VOLUME ["/data"]

# Copy in syslog config
RUN rm -f /etc/rsyslog.d/*
COPY build/rsyslog.conf /etc/rsyslog.conf

# It is expected that /data is = application/ in project folder
COPY application/ /data/

WORKDIR /data

# Fix folder permissions
RUN chown -R www-data:www-data \
    console/runtime/ \
    frontend/runtime/ \
    frontend/web/assets/

# Install/cleanup composer dependencies
RUN composer install --prefer-dist --no-interaction --no-dev --optimize-autoloader

EXPOSE 80
CMD ["apache2ctl", "-D", "FOREGROUND"]
