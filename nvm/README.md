# Excersize 2a
## Pepare mariadb AMI
Create golden image for mysql instances
```
cd packer
AWS_PROFILE=default packer build packer.json
```

## Prepare AWS infrastructure
Start 2x EC2 instances with mysql replication enabled and cloudwatch alerting for slave replication status
```
cd terraform
terraform apply -var 'aws_profile=default'
```

## Execute ex2.sh
Insert some data to database
```
export MYSQL_CMD='mysql --host <master_ip> --user admin'
./ex2.sh
```
