#!/bin/sh

mkdir /certs -p
cp /etc/ssl/certs/snakeoil.cer /certs/
cp /etc/ssl/private/snakeoil.key /certs/

cat > /etc/nginx/conf.d/proxy.conf << EOT
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen 443 ssl default;
    
    server_name ${SERVER_NAME:-_};
    ssl_certificate /etc/ssl/certs/snakeoil.cer;
    ssl_certificate_key /etc/ssl/private/snakeoil.key;
    
    location / {
        client_body_buffer_size ${CLIENT_BODY_BUFFER_SIZE:-128k};
        client_max_body_size ${CLIENT_MAX_BODY_SIZE:-16m};
        proxy_set_header Host ${PROXY_HOST:-\$host};
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Port \$server_port;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass ${PROXY_PASS:-http://upstream};
        proxy_redirect ${PROXY_REDIRECT:-default};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_buffering ${PROXY_BUFFERING:-off};
        proxy_connect_timeout ${PROXY_CONNECT_TIMEOUT:-60s};
        proxy_read_timeout ${PROXY_READ_TIMEOUT:-180s};
        proxy_send_timeout ${PROXY_SEND_TIMEOUT:-60s};
    }
}

server {
    listen 80 default;

    server_name ${SERVER_NAME:-_};
    return 301 https://\$server_name\$request_uri;
}
EOT

echo "Starting nginx"
exec nginx -g 'daemon off;'
