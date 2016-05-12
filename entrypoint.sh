#!/bin/bash

set -e

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

echo "daemon off;" >> /etc/nginx/nginx.conf

/usr/bin/service nginx start


