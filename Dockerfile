FROM ubuntu:14.04
MAINTAINER Ken Lee "kenmlee@163.com"

ENV REFRESHED_AT 2016-05-11

RUN apt-get -qq update \
    && apt-get upgrade -y \
    && apt-get install -y \
        python-pip \
        python-virtualenv \
        python-dev \
        libxml2-dev \
        zlib1g-dev \
        supervisor \
        libsasl2-modules \

RUN mkdir /srv \
    && rm /etc/nginx/sites-enabled/default \
    && chown -R www-data:www-data /srv/webvirtcloud

COPY webvirtcloud/ /srv/webvirtcloud

COPY webvirtcloud-nginx.conf /etc/nginx/conf.d/webvirtcloud.conf
COPY webvirtcloud-supervisor.conf /etc/supervisor/conf.d/webvirtcloud.conf

COPY settings.py /srv/webvirtcloud/webvirtcloud/settings.py

RUN cd /srv/webvirtcloud \
    && virtualenv venv \
    && . venv/bin/activate \
    && pip install --upgrade pip \
    && pip install -r conf/requirements.txt

RUN mkdir /var/www \
    && mkdir /var/www/.ssh \
    && touch /var/www/.ssh/config \
    && echo "StrictHostKeyChecking=no" >> /var/www/.ssh/config \
    && echo "UserKnownHostsFile=/dev/null" >> /var/www/.ssh/config \
    && chmod 0600 /var/www/.ssh/config

COPY wvc_rsa /var/www/.ssh/id_rsa
COPY wvc_rsa.pub /var/www/.ssh/id_rsa.pub

RUN chmod -R 0600 /var/www/.ssh/id_rsa \
    && chown -R www-data:www-data /var/www

EXPOSE 80 6080

COPY entrypoint.sh /entrypoint.sh
COPY init.sh /init.sh

RUN chmod +x /entrypoint.sh
    && chmod +x /init.sh

ENTRYPOINT "/entrypoint.sh"
