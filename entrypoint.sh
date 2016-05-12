#!/bin/bash
set -e

/usr/bin/service nginx start

/usr/bin/supervisord

