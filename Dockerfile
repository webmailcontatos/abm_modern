ARG UBUNTU_VERSION=22.04
ARG NGINX_VERSION=1.23.2
ARG POSTGRES_VERSION=14.2

# "ubuntu" stage
FROM ubuntu:${UBUNTU_VERSION} AS php

ENV PHP_VERSION=8.2
ENV NVM_VERSION='v0.39.2'
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo
ENV POSTGRES_PASSWORD=123456
ENV POSTGRES_USER=postgres
ENV POSTGRES_DB=dev


RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt install software-properties-common ca-certificates lsb-release apt-transport-https -y
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php  -y
RUN apt-get update -y
RUN apt-get install "php${PHP_VERSION}" -y
RUN apt-get install "php${PHP_VERSION}"-xml -y
RUN apt-get install "php${PHP_VERSION}"-memcached -y
RUN apt-get install "php${PHP_VERSION}"-curl -y
RUN apt-get install "php${PHP_VERSION}"-ldap -y
RUN apt-get install "php${PHP_VERSION}"-soap -y
RUN apt-get install "php${PHP_VERSION}"-imagick -y
RUN apt-get install "php${PHP_VERSION}"-apcu -y
RUN apt-get install "php${PHP_VERSION}"-zip -y
RUN apt-get install "php${PHP_VERSION}"-fpm -y
RUN apt-get install "php${PHP_VERSION}"-gd -y
RUN apt-get install "php${PHP_VERSION}"-mbstring -y
RUN apt-get install build-essential libssl-dev -y
RUN apt-get install postgresql-client -y
RUN apt-get install ssh -y
RUN apt-get install git -y
RUN apt-get install curl -y
RUN apt-get install vim -y
RUN apt-get install "php${PHP_VERSION}"-pgsql -y
RUN apt-get install iputils-ping -y
RUN apt-get install "php${PHP_VERSION}"-intl -y
RUN apt-get install rsync -y
RUN apt-get install "php${PHP_VERSION}"-zip -y
RUN apt-get install unzip -y
RUN apt-get install "php${PHP_VERSION}"-xdebug -y
RUN apt-get install "php${PHP_VERSION}"-tidy -y

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN touch ~/.bashrc
SHELL ["/bin/bash", "--login", "-i", "-c"]
RUN sed -r -e "s/\/run\/php\/php${PHP_VERSION}-fpm.sock/0.0.0.0:8000/g" -i /etc/php/$PHP_VERSION/fpm/pool.d/www.conf
RUN sed -r -e "s/display_errors = Off/display_errors = On/g" -i /etc/php/$PHP_VERSION/fpm/php.ini
RUN sed -r -e "s/max_execution_time = 30/max_execution_time = 300/g" -i /etc/php/$PHP_VERSION/fpm/php.ini
RUN sed -r -e "s/memory_limit = 128M/memory_limit = 512M/g" -i /etc/php/$PHP_VERSION/fpm/php.ini
RUN sed -r -e "s/upload_max_filesize = 2M/upload_max_filesize = 200M/g" -i /etc/php/$PHP_VERSION/fpm/php.ini
RUN sed -r -e "s/post_max_size = 8M/post_max_size = 80M/g" -i /etc/php/$PHP_VERSION/fpm/php.ini
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash
RUN nvm install --lts
SHELL ["/bin/bash", "--login", "-c"]
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY services/ubuntu/entrypoint.sh entrypoint.sh
COPY services/ubuntu/policy.xml /etc/ImageMagick-6/policy.xml
ENTRYPOINT ["./entrypoint.sh"]

# "nginx" stage
FROM nginx:${NGINX_VERSION} AS nginx
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y
RUN apt-get install vim -y
RUN apt-get install iputils-ping -y
RUN apt-get install nginx-common -y
RUN apt-get install libnginx-mod-http-lua -y
RUN apt-get install certbot python3-certbot-nginx -y
RUN apt-get install locales -y
RUN localedef -i pt_BR -c -f UTF-8 -A /etc/locale.alias pt_BR.UTF-8
ENV LANG pt_BR.utf8
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN sed -r -e "s/sendfile        on;/sendfile        off;/g" -i /etc/nginx/nginx.conf
RUN sed "16 i client_max_body_size 300M;" -i /etc/nginx/nginx.conf
RUN unlink /etc/nginx/conf.d/default.conf
RUN service nginx restart
CMD ["nginx", "-g", "daemon off;"]

# "postgres" stage
FROM postgres:${POSTGRES_VERSION} AS postgres
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y
RUN apt-get install vim -y
RUN apt-get install iputils-ping -y
RUN localedef -i pt_BR -c -f UTF-8 -A /usr/share/locale/locale.alias pt_BR.UTF-8
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG pt_BR.utf8
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

