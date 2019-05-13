#!/bin/bash -e

echo "Starting EntryPoint"
export POSTGRES_DB=${POSTGRES_DB:-datastore_default}
export POSTGRES_HOST=${POSTGRES_HOST}
export POSTGRES_USER=${POSTGRES_USER:-ckan_default}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

DATAPUSHER_HOME="/usr/lib/ckan/datapusher/src/datapusher"
CONFIG_TEMPLATE="$DATAPUSHER_HOME/deployment/datapusher_settings.py.unconfigured"
CONFIG="$DATAPUSHER_HOME/deployment/datapusher_settings.py"

echo "Running: envsubst"
envsubst < $CONFIG_TEMPLATE > $CONFIG

exec "$@"
