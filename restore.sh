#!/bin/bash

THISPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${THISPATH}/config.sh

INCLUDED=`cat ${THISPATH}/backup.sh | grep include`
echo "Paths included in the backup.sh:"
echo "---------"
echo $INCLUDED
echo "---------"
echo "example: ./restore.sh 0D var/www/site.com/htdocs/wp-content/uploads ./uploads/"
echo "---------"

if [ $# -lt 3 ]; then echo "Usage $0 <date> <file> <restore-to>"; exit; fi

duplicity \
    --restore-time $1 \
    --file-to-restore $2 \
    ${DEST} $3

# Reset the ENV variables. Don't need them sitting around
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
