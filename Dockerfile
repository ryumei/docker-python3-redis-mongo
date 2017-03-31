# To build in proxy
#  $ docker build --build-arg http_proxy=proxy:port .

# https://docs.docker.com/engine/admin/using_supervisord/#adding-supervisors-configuration-file
FROM ubuntu:16.04

ARG http_proxy
ARG https_proxy
ENV http_proxy $http_proxy
ENV https_proxy $https_proxy

RUN apt-get update \
 && apt-get install -y locales \
 && rm -rf /var/lib/apt/lists/* \
 && localedef -i ja_JP -c -f UTF-8 -A /usr/share/locale/locale.alias ja_JP.UTF-8 \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 \
 && echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list \
 && apt-get update \
 && apt-get install -y mongodb-org \
 && apt-get install -y wget build-essential \
 && mkdir -p /opt/local && cd /opt/local \
 && wget http://download.redis.io/redis-stable.tar.gz \
 && tar xvf redis-stable.tar.gz \
 && cd redis-stable \
 && make \
 && apt-get install -y supervisor \
 && mkdir -p /var/log/supervisor /etc/redis \
 && apt-get update \
 && apt-get install -y python3.5 python3-pip libffi-dev libssl-dev \
 && rm -rf /var/lib/apt/lists/*

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY redis_6379.conf /etc/redis/6379.conf
EXPOSE 27017 6379
ENV LANG ja_JP.utf8

CMD ["/usr/bin/supervisord"]

