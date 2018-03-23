#!/usr/bin/env bash

# ======================================================
# YOUR ENVIRONMENT VARIABLES
# ======================================================

# Set environment variables
export $(cat .env | grep -v ^# | xargs)


# Unset environment variables
unset $(cat .env | grep -v ^# | sed -E 's/(.*)=.*/\1/' | xargs)
