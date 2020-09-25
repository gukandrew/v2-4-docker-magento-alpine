FROM alpine:3.12
WORKDIR "/"

RUN apk add openrc openssl supervisor curl patch git ca-certificates \
  php7 php7-fpm php7-sockets php7-json php7-phar php7-iconv php7-openssl php7-session \
  php7-bcmath php7-ctype php7-curl php7-dom php7-gd php7-iconv php7-intl php7-json \
  php7-imap php7-mbstring php7-mcrypt php7-openssl php7-pdo_mysql php7-phar php7-zip \
  php7-simplexml php7-soap php7-tokenizer php7-xdebug php7-xml php7-xmlwriter php7-xsl \
  nginx && \
  sed -i 's/memory_limit = .*/memory_limit = 2048M/' /etc/php7/php.ini && \
  adduser -D -u 1000 -s /bin/bash www-data -G www-data && \
  rm -f /var/cache/apk/* && \
  curl -s https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && \
  mkdir -p /run/nginx && mkdir -p /run/php-fpm7 && \
  rc-update add nginx default && rc-update add php-fpm7 default && \
  rm -f /etc/nginx/conf.d/* && \
  mkdir -p /var/tmp/nginx && \
  chown -R www-data:www-data /var/tmp/nginx

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/vhost.conf /etc/nginx/conf.d/vhost.conf
COPY ./nginx/www.conf /etc/php7/php-fpm.d/www.conf
COPY ./xdebug.ini /etc/php7/conf.d/xdebug.ini

COPY ./supervisord.conf /etc/supervisord.conf
CMD ["supervisord", "-c", "/etc/supervisord.conf"]

EXPOSE 80 443
