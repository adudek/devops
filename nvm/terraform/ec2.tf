locals {
  master_ip = "172.31.16.11"
  slave_ip  = "172.31.16.12"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_default_vpc" "default" { }

resource "aws_security_group" "mysql_replication" {
  name        = "mysql-replication"
  description = "Allow mysql connection between mariadb instances"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [ "${chomp(data.http.myip.body)}/32" ]
  }

  ingress {
    self      = true
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
  }

  ingress {
    from_port   = 22 
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${chomp(data.http.myip.body)}/32" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

data "aws_ami" "mariadb" {
  most_recent      = true
  name_regex       = "^mariadb-\\d{14}"
  owners           = [ "self" ]
}

resource "aws_instance" "mysql_master" {
  ami               = data.aws_ami.mariadb.id
  instance_type     = "t2.micro"
  availability_zone = "${var.aws_region}a"
  key_name          = "personal"
  private_ip        = local.master_ip

  iam_instance_profile   = aws_iam_instance_profile.ec2_cloudwatch_logging.name
  vpc_security_group_ids = [ aws_security_group.mysql_replication.id ]

  tags = {
    Name = "mariadb-master"
  }

  user_data = <<-EOF
    #!/bin/bash -eu
    sudo echo '127.0.0.1 mysqlmaster' >> /etc/hosts
    sudo echo '${local.slave_ip} mysqlslave' >> /etc/hosts
    sudo cp /etc/my.cnf.d/config/master.cnf /etc/my.cnf.d/master.cnf
    sudo systemctl start mariadb
    MYSQL_REPLICATION_USER='${var.replication_user}' \
      MYSQL_REPLICATION_PASSWORD='${var.replication_password}' \
      MYSQL_ADMIN_USER='${var.admin_user}' \
      bash -eux /etc/my.cnf.d/config/master.sh
    EOF
}

resource "aws_instance" "mysql_slave" {
  ami               = data.aws_ami.mariadb.id
  instance_type     = "t2.micro"
  availability_zone = "${var.aws_region}a"
  key_name          = "personal"
  private_ip        = local.slave_ip

  iam_instance_profile   = aws_iam_instance_profile.ec2_cloudwatch_logging.name
  vpc_security_group_ids = [ aws_security_group.mysql_replication.id ]

  tags = {
    Name = "mariadb-slave"
  }

  user_data = <<-EOF
    #!/bin/bash -eu
    sudo echo '127.0.0.1 mysqlslave' >> /etc/hosts
    sudo echo '${aws_instance.mysql_master.private_ip} mysqlmaster' >> /etc/hosts
    sudo cp /etc/my.cnf.d/config/slave.cnf /etc/my.cnf.d/slave.cnf
    sudo systemctl start mariadb
    MYSQL_REPLICATION_USER='${var.replication_user}' \
      MYSQL_REPLICATION_PASSWORD='${var.replication_password}' \
      bash -eux /etc/my.cnf.d/config/slave.sh
    EOF
}
