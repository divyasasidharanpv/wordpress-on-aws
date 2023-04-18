#!/bin/bash

# Set variables
S3BUCKET="wp-project-backup"
DBNAME="wordpress"
DBUSER="wordpress"
DBPASS="secret"
DBHOST="localhost"
RDSHOST="<rds endpoint>"
RDSDB="wordpress"
RDSUSER="admin"
RDSPASS="password"

# Backup WordPress files
#zip -r /tmp/wordpress-files.zip /var/www/html
#aws s3 cp /tmp/wordpress-files.zip s3://$S3BUCKET/wordpress-files-$(date +%Y-%m-%d).zip
aws s3 sync /var/www/html/ s3://$S3BUCKET/wordpressfiles

# Backup database
mysqldump -h$DBHOST -u$DBUSER -p$DBPASS $DBNAME > /tmp/db.sql

# Restore to RDS
mysql -h$RDSHOST -u$RDSUSER -p$RDSPASS $RDSDB < /tmp/db.sql



# Add cron job if it doesn't already exist
if ! crontab -l | grep -q "/home/ubuntu/backup.sh"; then
  (crontab -l ; echo "0 20 * * * /home/ubuntu/backup.sh") | crontab -
fi

# Clean up
#rm /tmp/wordpress-files.zip
rm /tmp/db.sql
