#!/bin/bash

set -e

/usr/bin/service nginx start

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

exec "$@"
