FROM ubuntu:14.04
MAINTAINER Ken Lee "kenmlee@163.com"

ENV REFRESHED_AT 2016-05-11

RUN apt-get -qq update \
    && apt-get upgrade -y \
    && apt-get install -y \
        git \
        python-pip \
        python-virtualenv \
        python-dev \
        libxml2-dev \
        libvirt-dev \
        zlib1g-dev \
        supervisor \
        nginx \
        libsasl2-modules \
    && git clone https://github.com/retspen/webvirtcloud.git

RUN cd webvirtcloud \
    && cp conf/nginx/webvirtcloud.conf /etc/nginx/conf.d/ \
    && cd .. \
    && mv webvirtcloud /srv \
    && cd /srv/webvirtcloud \
    && virtualenv venv \
    && . venv/bin/activate \
    && pip install --upgrade pip \
    && pip install -r conf/requirements.txt \
    && python manage.py migrate \
    && rm /etc/nginx/sites-enabled/default \
    && chown -R www-data:www-data /srv/webvirtcloud

RUN mkdir /var/www \
    && mkdir /var/www/.ssh \
    && touch /var/www/.ssh/config \
    && echo "StrictHostKeyChecking=no" >> /var/www/.ssh/config \
    && echo "UserKnownHostsFile=/dev/null" >> /var/www/.ssh/config \
    && chmod 0600 /var/www/.ssh/config

COPY webvirtcloud_rsa /var/www/.ssh/id_rsa
COPY webvirtcloud.conf /etc/supervisor/conf.d/webvirtcloud.conf

RUN chmod -R 0600 /var/www/.ssh/id_rsa \
    && chown -R www-data:www-data /var/www 

ENTRYPOINT "/usr/bin/supervisord"

EXPOSE 80 6080 
