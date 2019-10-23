output "master" {
  value = {
    ip = aws_instance.mysql_master.public_ip
    id = aws_instance.mysql_master.id
  }
}

output "slave" {
  value = {
    ip = aws_instance.mysql_slave.public_ip
    id = aws_instance.mysql_slave.id
  }
}

output "mysql_cmd" {
  value = "mysql --host ${aws_instance.mysql_master.public_ip} --user admin"
}
