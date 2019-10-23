#!/bin/bash -eu

#mysqladmin -u root -proot password ''
mysql -uroot -AN -e 'STOP SLAVE'
mysql -uroot -AN -e 'RESET SLAVE ALL'
mysql -uroot -AN -e "CHANGE MASTER TO master_host='mysqlmaster', master_port=3306,
  master_user='$MYSQL_REPLICATION_USER', master_password='$MYSQL_REPLICATION_PASSWORD'"
mysql -uroot -AN -e 'START SLAVE'
mysql -uroot -AN -e 'SET GLOBAL max_connections=2000'
mysql -uroot -e 'SHOW SLAVE STATUS \G'
