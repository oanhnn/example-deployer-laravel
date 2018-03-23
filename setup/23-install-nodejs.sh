#!/usr/bin/env bash

# ======================================================
# Install Node.js
# ======================================================

# Set environment variables
export $(cat .env | grep -v ^# | xargs)

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get update
apt-get install -y nodejs
echo "[✔] Install NodeJS"
node --version

# Unset environment variables
unset $(cat .env | grep -v ^# | sed -E 's/(.*)=.*/\1/' | xargs)
