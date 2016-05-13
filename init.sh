#! /bin/bash

cd /srv/webvirtcloud
source venv/bin/activate
python manage.py migrate
