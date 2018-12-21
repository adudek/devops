# TeamCity

## TeamCity Server container installation Linux (AWS headles)

```
#!/bin/bash
# install Docker service and run TeamCity server container
amazon-linux-extras install docker
systemctl enable docker --now
docker volume create tcdata
docker volume create tclogs
docker run -d --name teamcity-server -v tcdata:/data/teamcity_server/datadir -v tclogs:/opt/teamcity/logs -p8111:8111 --expose 8111 jetbrains/teamcity-server

# install Nginx proxy service and route port localhost:8111 to *:80
cat > /home/ec2-user/nginx.conf << EOF
events { }

http {

  map \$http_upgrade \$connection_upgrade {
    default upgrade;
    '' '';
  }

  server {
    listen       80;
    server_name  "";

    access_log off;

    client_max_body_size        500M;
    client_body_buffer_size     500M;

    location / {
    proxy_pass         http://localhost:8111;

    proxy_set_header   Host             \$host;
    proxy_set_header   X-Real-IP        \$remote_addr;
    proxy_set_header   X-Forwarded-For  \$proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto http;

    proxy_set_header   X-Forwarded-Host \$http_host;
    proxy_set_header   Upgrade \$http_upgrade;
    proxy_set_header   Connection \$connection_upgrade;

    proxy_max_temp_file_size 0;

    proxy_connect_timeout      240;
    proxy_send_timeout         300;
    proxy_read_timeout         1200;

    proxy_buffer_size          512k;
    proxy_buffers              32 4m;
    proxy_busy_buffers_size    25m;
    proxy_temp_file_write_size 10m;
    }
  }
}

EOF

docker run -d --name teamcity-proxy --network host -v /home/ec2-user/nginx.conf:/etc/nginx/nginx.conf -p80:80 -p443:443 nginx
```
