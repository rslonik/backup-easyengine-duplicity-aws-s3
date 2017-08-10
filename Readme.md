# BACKUP

How to use
-------------

* Configure config.sh with key, email and AWS S3 bucket address.

* bash backup.sh (will install Duplicity and Cron jobs).

* That's all. It will do a full backup every 30 days, with incremental every day.

*This backup script is intented to be used within a EasyEngine install*.
