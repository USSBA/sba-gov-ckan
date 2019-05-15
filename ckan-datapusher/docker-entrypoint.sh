#!/bin/bash -e

ERROR=0

export DATAPUSHER_PORT=${DATAPUSHER_PORT:-8800}
([ ! -z "$DATAPUSHER_FQDN" ] && export DATAPUSHER_FQDN=$DATAPUSHER_FQDN) || (echo "FATAL: DATAPUSHER_FQDN is not configured" && ERROR=1)

if [ $ERROR -eq 1 ]; then
  echo "Configuration errors above must be corrected before this container can start.  Ensure all environment variables are set properly."
  echo "$@" >&2
  exit 1
else
  echo "All environment variables are properly set."
fi

DIR="/usr/lib/ckan/datapusher/src/datapusher"
CONF_FILE="$DIR/deployment/datapusher_settings.py"
CONF_TMPL="$CONF_FILE.unconfigured"

# echo "Running: envsubst"
envsubst < $CONF_TMPL > $CONF_FILE

exec "$@"
