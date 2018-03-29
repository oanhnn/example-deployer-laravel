#!/usr/bin/env bash

# ======================================================
# YOUR ENVIRONMENT VARIABLES
# ======================================================

# Set environment variables
export $(cat .env | grep -v ^# | xargs)

mkdir -p /apps/$DOMAIN/releases
mkdir -p /apps/$DOMAIN/shared
chown -R $USER:www-data /apps/$DOMAIN

# Unset environment variables
unset $(cat .env | grep -v ^# | sed -E 's/(.*)=.*/\1/' | xargs)
