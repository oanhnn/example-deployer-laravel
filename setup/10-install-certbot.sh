#!/usr/bin/env bash

# ======================================================
# Setup certbot
# ======================================================

# Set environment variables
export $(cat .env | grep -v ^# | xargs)

# Install Certbot
apt-get install -y certbot
echo "[✔] Install Certbot"

# Make SSL certificate
certbot certonly --standalone --preferred-challenges http -d $DOMAIN -d www.$DOMAIN
echo "[✔] Make SSL certificate for $DOMAIN"

# Setup auto renew
echo '02 20 * * 03 sleep $[($RANDOM % 60) + 1]m; /usr/bin/certbot renew --pre-hook "/usr/sbin/service nginx stop" --post-hook "/usr/sbin/service nginx start" --quiet --no-self-upgrade' | crontab -u root -
echo "[✔] Setup auto renew SSL"

# Unset environment variables
unset $(cat .env | grep -v ^# | sed -E 's/(.*)=.*/\1/' | xargs)
