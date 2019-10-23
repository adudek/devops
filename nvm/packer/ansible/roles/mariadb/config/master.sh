#!/bin/bash -eu

#mysqladmin -u root -proot password ''
mysql -uroot -AN -e "CREATE USER '$MYSQL_REPLICATION_USER'@'%'"
mysql -uroot -AN -e "GRANT REPLICATION SLAVE ON *.* TO '$MYSQL_REPLICATION_USER' IDENTIFIED BY '$MYSQL_REPLICATION_PASSWORD'"
mysql -uroot -AN -e 'FLUSH PRIVILEGES'
mysql -uroot -AN -e "CHANGE MASTER TO master_host='mysqlslave', master_port=3306,
  master_user='$MYSQL_REPLICATION_USER', master_password='$MYSQL_REPLICATION_PASSWORD'"
mysql -uroot -AN -e 'SET GLOBAL max_connections=2000'

mysql -uroot -AN -e "CREATE USER 'heartbeat'@'%'"
mysql -uroot -AN -e "GRANT ALL ON heartbeat.* TO 'heartbeat' IDENTIFIED BY 'pass'"
mysql -uroot -AN -e 'CREATE DATABASE heartbeat'
mysql -uroot -AN -Dheartbeat -e 'CREATE TABLE timestamp (created TIMESTAMP PRIMARY KEY DEFAULT CURRENT_TIMESTAMP)'
mysql -uroot -Dheartbeat -e 'INSERT INTO timestamp () VALUES ()'

mysql -uroot -AN -e "CREATE USER 'admin'@'%'"
mysql -uroot -AN -e "GRANT ALL ON *.* TO '$MYSQL_ADMIN_USER' WITH GRANT OPTION"
