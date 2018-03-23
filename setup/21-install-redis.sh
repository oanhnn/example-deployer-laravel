#!/usr/bin/env bash

# ======================================================
# Install & Configure Redis Server
# ======================================================

# Set environment variables
export $(cat .env | grep -v ^# | xargs)

apt-get install -y redis-server
#sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf
systemctl enable redis-server
service redis-server restart

# Unset environment variables
unset $(cat .env | grep -v ^# | sed -E 's/(.*)=.*/\1/' | xargs)
