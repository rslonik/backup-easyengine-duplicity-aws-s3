#!/bin/bash

THISPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${THISPATH}/config.sh

duplicity verify -v4 ${DEST} ${SOURCE}\
    --include=/var/www \
    --exclude=/** \
    --exclude=/root/.cache 

# Reset the ENV variables. Don't need them sitting around
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
