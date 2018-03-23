#!/usr/bin/env bash

# ======================================================
# Install & Configure NGINX
# ======================================================

# Set environment variables
export $(cat .env | grep -v ^# | xargs)

# Install Nginx
apt-get install -y nginx
systemctl enable nginx
service nginx restart
echo "[✔] Install NGINX"

# Change NGINX user
sed -i "s|^user .*|user www-data;|i" /etc/nginx/nginx.conf
echo "[✔] Change NGINX user"

# Generate dhparam File
openssl dhparam -out /etc/nginx/dhparams.pem 2048
echo "[✔] Generate dhparam file"

# Disable the default NGINX site
rm /etc/nginx/sites-enabled/default
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/99-default-bakup
echo "[✔] Disable the default NGINX site"

# Configure upsteams and http upgrade
cat > /etc/nginx/conf.d/php-fpm-upsteam.conf << EOF
upstream php-fpm {
    server unix:/run/php/php7.1-fpm.sock;
}
EOF
cat > /etc/nginx/conf.d/http_upgrade.conf << EOF
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
}
EOF
echo "[✔] Configure upsteams and http upgrade"

# Install A Catch All Server
cat > /etc/nginx/sites-available/99-catch-all << EOF
server {
    return 404;
}
EOF
ln -s /etc/nginx/sites-available/99-catch-all /etc/nginx/sites-enabled/99-catch-all
echo "[✔] Config a catch all server"

# Install A PHP WebApp Server
cat > /etc/nginx/sites-available/01-webapp << EOF
server {
    listen 80;
    listen [::]:80;

    server_name $DOMAIN www.$DOMAIN;
    server_tokens off;

    location / {
        return  301 https://$server_name$request_uri;
    }
}

server {
    listen 443;
    listen [::]:443;

    root /apps/$DOMAIN/current/public;
    index index.php index.html index.htm;

    server_name $DOMAIN www.$DOMAIN;
    server_tokens off;

    ssl on;

    ssl_certificate     /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    ssl_protocols              TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers  on;
    ssl_ciphers                ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA;
    ssl_session_cache          shared:SSL:10m;
    ssl_session_timeout        30m;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \\.php$ {
       include snippets/fastcgi-php.conf;
       fastcgi_pass php-fpm;
    }

    location ~* \\.(?:manifest|appcache|html?|xml|json)\$ {
        expires -1;
    }

    location ~* \\.(?:rss|atom)\$ {
        expires 1h;
        add_header Cache-Control "public";
    }

    location ~* \\.(?:css|js|map)\$ {
        expires 1M;
        add_header Cache-Control "public";
    }

    location ~* \\.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc|ttf|ttc|otf|eot|woff|woff2)\$ {
        expires 1M;
        add_header Cache-Control "public";
    }

    location ~ /\\.ht {
       deny all;
    }
}
EOF
ln -s /etc/nginx/sites-available/01-webapp /etc/nginx/sites-enabled/01-webapp
echo "[✔] Config A PHP Web Application Server"

# Restart Nginx
nginx -t
service nginx reload
echo "[✔] Reload NGINX service"

# Unset environment variables
unset $(cat .env | grep -v ^# | sed -E 's/(.*)=.*/\1/' | xargs)
