#!/usr/bin/env bash

# ======================================================
# YOUR ENVIRONMENT VARIABLES
# ======================================================

# Set environment variables
export $(cat .env | grep -v ^# | xargs)

# Setup cron job for schedule:run command
rm -rf /tmp/cron-dev && touch /tmp/cron-dev
crontab -u dev -l > /tmp/cron-dev
echo "* * * * * php /apps/$DOMAIN/current/artisan schedule:run >> /dev/null 2>&1" >> /tmp/cron-dev
cat /tmp/cron-dev | crontab -u dev -

# Unset environment variables
unset $(cat .env | grep -v ^# | sed -E 's/(.*)=.*/\1/' | xargs)
