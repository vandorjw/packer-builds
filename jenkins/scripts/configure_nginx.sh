#!/bin/bash

# remove old nginx config
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-available/default

# use the following nginx config file
cat << EOF | sudo tee /etc/nginx/sites-available/default > /dev/null
server {
  listen 80 default_server;
  listen [::]:80 default_server;

  server_name _;

    client_max_body_size 10M;
    etag on;

    location / {
      proxy_cache_revalidate on;

      proxy_set_header        Host \$host:\$server_port;
      proxy_set_header        X-Real-IP \$remote_addr;
      proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto \$scheme;

      # Fix the "It appears that your reverse proxy set up is broken" error.
      proxy_pass          http://127.0.0.1:8080;
      proxy_read_timeout  90;

      proxy_redirect      http://127.0.0.1:8080 https://\$host:\$server_port;

      # Required for new HTTP-based CLI
      proxy_http_version 1.1;
    }
}
EOF

# create a symbolic link to sites-enabled
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
