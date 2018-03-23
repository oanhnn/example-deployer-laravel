#!/usr/bin/env bash

# ======================================================
# Install & Configure Memcached
# ======================================================

# Set environment variables
export $(cat .env | grep -v ^# | xargs)

apt-get install -y memcached
#sed -i 's/-l 127.0.0.1/-l 0.0.0.0/' /etc/memcached.conf
systemctl enable memcached
service memcached restart

# Unset environment variables
unset $(cat .env | grep -v ^# | sed -E 's/(.*)=.*/\1/' | xargs)
