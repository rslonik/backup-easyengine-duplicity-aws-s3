#!/bin/bash

THISPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${THISPATH}/config.sh

### UTILS ###
# Incluir qualquer coisa na cron
# Uso: GenCron "script.sh" "minuto" "hora" "dia_semana"
GenCron(){
  if ! crontab -l | grep "$1"; then
    LINHACRON="$2 $3 * * $4 /bin/bash $1";
    TEMPCRON=`mktemp`;
    crontab -l > $TEMPCRON;
    echo "$LINHACRON > /dev/null" >> $TEMPCRON;
    crontab $TEMPCRON;
    rm -f $TEMPCRON;
  fi
}
### ###

duplicity --version
if [ ! $? -eq 0 ]; then
  echo
  echo "Installing Duplicity"
  echo
  apt-add-repository ppa:duplicity-team/ppa
  apt-get update
  apt-get install duplicity python-pip mailutils -y
  pip install boto
fi

GenCron "${THISPATH}/mysqldump.sh" 0 3 '*'
GenCron "${THISPATH}/backup.sh" 0 4 '*'

# Set up some variables for logging
LOGFILE="/var/log/duplicity/backup.log"
DAILYLOGFILE="/var/log/duplicity/backup.daily.log"
FULLBACKLOGFILE="/var/log/duplicity/backup.full.log"
HOST=`hostname`
DATE=`date +%Y-%m-%d`
TODAY=$(date +%d%m%Y)
LASTMONTHTODAY=$(date -d 'now - 30 days' +%d%m%Y)

is_running=$(ps -ef | grep duplicity  | grep python | wc -l)

if [ ! -d /var/log/duplicity ];then
    mkdir -p /var/log/duplicity
fi

if [ ! -f $FULLBACKLOGFILE ]; then
    touch $FULLBACKLOGFILE
fi

if [ $is_running -eq 0 ]; then
    # Clear the old daily log file
    cat /dev/null > ${DAILYLOGFILE}

    # Trace function for logging, don't change this
    trace () {
            stamp=`date +%Y-%m-%d_%H:%M:%S`
            echo "$stamp: $*" >> ${DAILYLOGFILE}
    }

    # How long to keep backups for
    OLDER_THAN="1M"

    # The source of your backup
    SOURCE=/

    if [ $(wc -l $FULLBACKLOGFILE | cut -d' ' -f 1) -eq 0 ]; then
        echo $LASTMONTHTODAY >> ${FULLBACKLOGFILE}
    fi

    tail ${FULLBACKLOGFILE} | grep $LASTMONTHTODAY > /dev/null
    if [ $? -eq 0 ]; then
	FULL=full
    fi;

    trace "Backup for local filesystem started"

    trace "... removing old backups"

    duplicity remove-all-but-n-full 1 ${DEST} >> ${DAILYLOGFILE} 2>&1

    trace "... backing up filesystem"

    duplicity \
        ${FULL} \
        --no-encryption \
        --include=/var/www \
        --include=/mnt/vdb/uploads \
        --exclude=/** \
        ${SOURCE} ${DEST} >> ${DAILYLOGFILE} 2>&1

    trace "Backup for local filesystem complete"
    trace "------------------------------------"

    # Send the daily log file by email
    BACKUPSTATUS=`cat "$DAILYLOGFILE" | grep Errors | awk '{ print $2 }'`
    if [ "$BACKUPSTATUS" != "0" ]; then
	   cat "$DAILYLOGFILE" | mail -s "Duplicity Backup Log for $HOST - $DATE" $MAILADDR
    elif [ "$FULL" = "full" ]; then
        echo "$(date +%d%m%Y_%T) Full Back Done" >> $FULLBACKLOGFILE
    fi

    # Append the daily log file to the main log file
    cat "$DAILYLOGFILE" >> $LOGFILE
    cat $DAILYLOGFILE

    # Reset the ENV variables. Don't need them sitting around
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
fi
