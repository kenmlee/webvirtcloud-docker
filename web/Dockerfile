FROM nginx:1.10.0
MAINTAINER Ken Lee "kenmlee@163.com"

ENV REFRESHED_AT 2016-05-15

COPY nginx.conf /etc/nginx/nginx.conf
COPY webvirtcloud-nginx.conf /etc/nginx/conf.d/webvirtcloud.conf

RUN rm /etc/nginx/conf.d/default.conf
