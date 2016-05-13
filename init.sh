#! /bin/bash

if [ -z $DB_ENV_POSTGRES_USER ]; then
    USERNAME=postgres
else
    USERNAME=$DB_ENV_POSTGRES_USER
fi

if [ -n $DB_ENV_POSTGRES_PASSWORD ]; then
    PASSWORD=$DB_ENV_POSTGRES_PASSWORD
elif [ -n $DB_PASSWORD ]; then
    PASSWORD=$DB_PASSWORD
else
    echo "You need set env DB_PASSWORD"
    exit 1
fi

# create database
psql -v ON_ERROR_STOP=1 -d postgres://$USERNAME:$PASSWORD@db <<-EOSQL
    CREATE USER wvc;
    CREATE DATABASE wvc;
    GRANT ALL PRIVILEGES ON DATABASE wvc TO wvc;
EOSQL

cd /srv/webvirtcloud
source venv/bin/activate
python manage.py migrate
