#!/bin/bash

set -e

# check /var/run/libvirt/libvirt-sock
if [ -a "/var/run/libvirt/libvirt-sock" ]; then
    GID=`ls -l /var/run/libvirt/libvirt-sock | awk '{print $4}'`
    if [ ${GID} != "libvirtd" ]; then
        addgroup --gid ${GID} libvirtd
    fi
    usermod -a -G libvirtd www-data
fi

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
