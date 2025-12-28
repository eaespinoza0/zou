#!/bin/bash
set -e

# Read secrets from /run/secrets/ and export as environment variables
# Secrets are mounted by Docker Compose

if [ -f /run/secrets/secret_key ]; then
  export SECRET_KEY=$(cat /run/secrets/secret_key | tr -d '\n\r ')
fi

if [ -f /run/secrets/db_password ]; then
  export DB_PASSWORD=$(cat /run/secrets/db_password | tr -d '\n\r ')
fi

if [ -f /run/secrets/mail_password ]; then
  export MAIL_PASSWORD=$(cat /run/secrets/mail_password | tr -d '\n\r ')
fi

if [ -f /run/secrets/indexer_key ]; then
  export INDEXER_KEY=$(cat /run/secrets/indexer_key | tr -d '\n\r ')
fi

# Execute the command passed to the container
exec "$@"

