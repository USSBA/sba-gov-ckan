#!/bin/bash -e

ERROR=0

export DATAPUSHER_PORT=${DATAPUSHER_PORT:-8800}

DIR="/usr/lib/ckan/datapusher/src/datapusher"
CONF_FILE="$DIR/deployment/datapusher_settings.py"
CONF_TMPL="$CONF_FILE.unconfigured"

# echo "Running: envsubst"
envsubst < $CONF_TMPL > $CONF_FILE

exec "$@"
