#!/bin/bash

source /usr/local/sbin/config.sh

if [ $# -lt 1 ]; then echo "Usage $0 <path>"; exit; fi

duplicity list-current-files ${DEST}$1 

# Reset the ENV variables. Don't need them sitting around
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
