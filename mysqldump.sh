#!/bin/sh

THISPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${THISPATH}/config.sh

LOGFILE="/var/log/duplicity/mysqldump.log"
DATE=`date +%Y-%m-%d`

if [ ! -d /var/log/duplicity ];then
    mkdir -p /var/log/duplicity
fi

if [ ! -f $LOGFILE ]; then
    touch $LOGFILE
fi

for SITE in $(ee site list | grep -v example.com | sort | sed 's/\x1B\[[0-9;]*[JKmsu]//g')
	do
		DBNAME=$(cat /var/www/$SITE/wp-config.php | grep DB_NAME | cut -d"'" -f4)
		mysqldump -u root $DBNAME | gzip > /var/www/$SITE/$DBNAME.sql.gz
		if [ ! $? -eq 0 ]; then
			echo "[ERROR]" $DATE $SITE >> $LOGFILE
			cat $LOGFILE | mail -s "Mysqldump Error for- $DATE" $MAILADDR
		fi
		echo "[OK]" $DATE $SITE >> $LOGFILE
done

echo >> $LOGFILE
echo "------------------------" >> $LOGFILE
echo >> $LOGFILE
