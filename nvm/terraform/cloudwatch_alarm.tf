resource "aws_cloudwatch_metric_alarm" "mysql_replication_timeout" {
  alarm_name          = "mysql-replication-timeout"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 1
  alarm_description   = "Replication delay alert"
  datapoints_to_alarm = 1
  treat_missing_data  = "breaching"
  insufficient_data_actions = []

  metric_name = "MysqlReplicationDelay"
  period      = 60
  statistic   = "Minimum"
  unit        = "Seconds"
  namespace   = "Custom"
  dimensions  = {
    InstanceID = aws_instance.mysql_slave.id
  }
}
