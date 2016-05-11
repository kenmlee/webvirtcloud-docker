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
    && cp conf/supervisor/webvirtcloud.conf /etc/supervisor/conf.d/ \
    && cp conf/ngnix/webvirtcloud.conf /etc/nginx/conf.d/ \
    && cd .. \
    && mv webvirtcloud /srv \
    && cd /srv/webvirtcloud \
    && virtualenv venv \
    && source venv/bin/activate \
    && pip install -r conf\requirements.txt \
    && python manage.py migrate \
    && rm /etc/nginx/sites-enabled/default \
    && service nginx restart

# ENTRYPOINT "/usr/bin/supervisord"
CMD ["/usr/bin/supervisord", "-n"]

EXPOSE 80
