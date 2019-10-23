#!/bin/bash -u


/usr/bin/sleep 15s
document="$(/usr/bin/curl -s http://169.254.169.254/latest/dynamic/instance-identity/document)"
instanceId=$(/usr/bin/jq -r '.instanceId' <<< "${document}")
current_region=$(/usr/bin/jq -r '.region' <<< "${document}")
while true; do
  master_time=9999999999
  slave_time=0
  /usr/bin/mysql --host mysqlmaster -uheartbeat -ppass -e 'INSERT INTO `heartbeat`.`timestamp` () VALUES ()'
  master_time=$(/usr/bin/mysql --host mysqlmaster -uheartbeat -ppass -ANs -e 'SELECT UNIX_TIMESTAMP(MAX(created)) FROM `heartbeat`.`timestamp`') || master_time=9999999999
  slave_time=$(/usr/bin/mysql --host mysqlslave -uheartbeat -ppass -ANs -e 'SELECT UNIX_TIMESTAMP(MAX(created)) FROM `heartbeat`.`timestamp`') || slave_time=0
  /usr/bin/aws --region ${current_region} cloudwatch put-metric-data \
    --metric-name MysqlReplicationDelay \
    --namespace Custom \
    --unit Seconds --value $(( ${master_time} - ${slave_time} )) \
    --dimensions InstanceID=${instanceId} || true
  /usr/bin/sleep 1s
done
