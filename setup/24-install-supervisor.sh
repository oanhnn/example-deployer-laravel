#!/usr/bin/env bash

# ======================================================
# Setup & Configure supervisor
# ======================================================

# Set environment variables
export $(cat .env | grep -v ^# | xargs)

apt-get install -y supervisor
systemctl enable supervisor.service
service supervisor start

# Unset environment variables
unset $(cat .env | grep -v ^# | sed -E 's/(.*)=.*/\1/' | xargs)
