#! /bin/bash
username=postgres

if [ $DB_ENV_POSTGRES_USER ]; then
    username=$DB_ENV_POSTGRES_USER
fi

if [ $DB_ENV_POSTGRES_PASSWORD ]; then
    password=$DB_ENV_POSTGRES_PASSWORD
elif [ $DB_PASSWORD ]; then
    password=$DB_PASSWORD
else
    echo "You need set env DB_PASSWORD"
    exit 1
fi

# echo "username:"$username
# echo "password:"$password

# update password field in setttings.py
set -i "s/wvcpasswd/$password/g" /srv/webvirtcloud/webvirtcloud/setttings.py

# create database
psql -v ON_ERROR_STOP=1 -d postgres://$username:$password@db <<-EOSQL
    CREATE USER wvc WITH PASSWORD '${password}';
    CREATE DATABASE wvc;
    GRANT ALL PRIVILEGES ON DATABASE wvc TO wvc;
EOSQL

cd /srv/webvirtcloud
source venv/bin/activate

# A bug in migration "0002" of App logs.
# I worked out a workaround
sed -i 's/AddField/AlterField/g' logs/migrations/0002_auto_20150316_1420.py

# due some bug in Django 1.8. We must run "migrate auth" first otherwise
# contenttypes will failed sometime when try to migration.
python manage.py migrate auth

python manage.py migrate
