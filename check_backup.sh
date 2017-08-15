#!/bin/bash
THISPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${THISPATH}/config.sh

HOST=`hostname`
DATE=`date +%Y-%m-%d`
MYSQLLOGFILE="/var/log/duplicity/mysqldump.log"


for SITE in $(ee site list | grep -v example.com | sort | sed 's/\x1B\[[0-9;]*[JKmsu]//g')
do
	DBNAME=$(cat /var/www/$SITE/wp-config.php | grep DB_NAME | cut -d"'" -f4)
	
	# Input file
	FILE=/var/www/$SITE/$DBNAME.sql.gz
	# How many seconds before file is deemed "older"
	OLDTIME=86400
	# Get current and file times
	CURTIME=$(date +%s)
	FILETIME=$(stat $FILE -c %Y)
	TIMEDIFF=$(expr $CURTIME - $FILETIME)

	# Check if file older
	if [ $TIMEDIFF -gt $OLDTIME ]; then
		SENDEMAIL=true
	fi
	
done

if [ "$SENDEMAIL" = true ]; then
	tail -n 20 "$MYSQLLOGFILE" | mail -s "Duplicity Backup Log for $HOST - $DATE" $MAILADDR
	SENDEMAIL=false
fi

