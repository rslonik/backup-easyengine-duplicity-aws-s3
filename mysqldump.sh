#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
LOGFILE="/var/log/duplicity/mysqldump.log"
THISPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo 'mysqldump' >> $LOGFILE

source ${THISPATH}/config.sh

DATE=`date +%Y-%m-%d`

if [ ! -d /var/log/duplicity ];then
    mkdir -p /var/log/duplicity
fi

if [ ! -f $LOGFILE ]; then
    touch $LOGFILE
fi

for SITE in $(ee site list | grep -v example.com | sort | sed 's/\x1B\[[0-9;]*[JKmsu]//g')
	do
		echo $SITE >> $LOGFILE
		DBNAME=$(cat /var/www/$SITE/wp-config.php | grep DB_NAME | cut -d"'" -f4)
		/usr/bin/mysqldump -u root $DBNAME | gzip > /var/www/$SITE/$DBNAME.sql.gz
		if [ ! $? -eq 0 ]; then
			echo "[ERROR]" $DATE $SITE >> $LOGFILE
			cat $LOGFILE | mail -s "Mysqldump Error for- $DATE" $MAILADDR
		fi
		echo "[OK]" $DATE $SITE >> $LOGFILE
done

echo >> $LOGFILE
echo "------------------------" >> $LOGFILE
echo >> $LOGFILE
