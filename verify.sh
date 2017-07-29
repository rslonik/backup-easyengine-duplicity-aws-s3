#!/bin/bash

source /usr/local/sbin/config.sh

duplicity verify -v4 ${DEST} ${SOURCE}\
    --include=/var/www \
    --exclude=/** \
    --exclude=/root/.cache 

# Reset the ENV variables. Don't need them sitting around
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
