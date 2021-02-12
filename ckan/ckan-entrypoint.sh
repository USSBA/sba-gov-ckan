#!/bin/bash -e

ERROR=0

# CKAN
# configuration for the ckan application

export CKAN_PORT=${CKAN_PORT:-80}
export CKAN_SITE_ID=${CKAN_SITE_ID:-default}
([ ! -z "$CKAN_SITE_URL" ] && export CKAN_SITE_URL=$CKAN_SITE_URL) || (echo "FATAL: CKAN_SITE_URL is not configured" && ERROR=1)
([ ! -z "$SESSION_SECRET" ] && export SESSION_SECRET=$SESSION_SECRET) || (echo "FATAL: SESSION_SECRET is not configured" && ERROR=1)
([ ! -z "$APP_UUID" ] && export APP_UUID=$APP_UUID) || (echo "FATAL: APP_UUID is not configured" && ERROR=1)

# POSTGRES
# configuration for the postgresql database

export POSTGRES_DB=${POSTGRES_DB:-ckan_default}
export POSTGRES_USER=${POSTGRES_USER:-ckan_default}
export POSTGRES_PORT=${POSTGRES_PORT:-5432}
([ ! -z "$POSTGRES_PASSWORD" ] && export POSTGRES_PASSWORD=$POSTGRES_PASSWORD) || (echo "FATAL: POSTGRES_PASSWORD is not configured" && ERROR=1)
([ ! -z "$POSTGRES_FQDN" ] && export POSTGRES_FQDN=$POSTGRES_FQDN) || (echo "FATAL: POSTGRES_FQDN is not configured" && ERROR=1)
export CKAN_SQLALCHEMY_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_FQDN}/${POSTGRES_DB}

# DATASTORE
# configuration for the datastore database

export DATASTORE_DB=${DATASTORE_DB:-datastore_default}
export DATASTORE_ROLENAME=${DATASTORE_ROLENAME:-datastore_default}
export CKAN_DATASTORE_WRITE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_FQDN}/${DATASTORE_DB}
export CKAN_DATASTORE_READ_URL=postgresql://${DATASTORE_ROLENAME}:${POSTGRES_PASSWORD}@${POSTGRES_FQDN}/${DATASTORE_DB}

# REDIS
# configuration for the redis database

export REDIS_PORT=${REDIS_PORT:-6379}
export REIDS_DBID=${REDIS_DBID:-1}
([ ! -z "$REDIS_FQDN" ] && export REDIS_FQDN=$REDIS_FQDN) || (echo "FATAL: REDIS_FQDN is not configured" && ERROR=1)
export CKAN_REDIS_URL=redis://${REDIS_FQDN}:${REDIS_PORT}/${REDIS_DBID}

# SOLR
# configuration for the solr database

export SOLR_PORT=${SOLR_PORT:-8983}
export SOLR_CORE_NAME=${SOLR_CORE_NAME:-ckan}
export SOLR_HTTP_SCHEME=${SOLR_HTTP_SCHEME:-http}
([ ! -z "$SOLR_FQDN" ] && export SOLR_FQDN=$SOLR_FQDN) || (echo "FATAL: SOLR_FQDN is not configured" && ERROR=1)
export CKAN_SOLR_URL=${SOLR_HTTP_SCHEME}://${SOLR_FQDN}:${SOLR_PORT}/solr/${SOLR_CORE_NAME}

# DATAPUSHER
# configuration for the datapusher

export DATAPUSHER_PORT=${DATAPUSHER:-8800}
export DATAPUSHER_HTTP_SCHEME=${DATAPUSHER_HTTP_SCHEME:-http}
([ ! -z "$DATAPUSHER_FQDN" ] && export DATAPUSHER_FQDN=$DATAPUSHER_FQDN) || (echo "FATAL: DATAPUSHER_FQDN is not configured" && ERROR=1)
export CKAN_DATAPUSHER_URL=${DATAPUSHER_HTTP_SCHEME}://${DATAPUSHER_FQDN}:${DATAPUSHER_PORT}

# SMTP
# configuration for the smtp

export SMTP_FQDN=${SMTP_FQDN:-email-smtp.us-east-1.amazonaws.com}
export SMTP_PORT=${SMTP_PORT:-587}
export CKAN_SMTP_STARTTLS=${CKAN_SMTP_STARTTLS:-True}
export CKAN_SMTP_SERVER=${SMTP_FQDN}:${SMTP_PORT}
([ ! -z "$CKAN_SMTP_USER" ] && export CKAN_SMTP_USER=$CKAN_SMTP_USER) || (echo "FATAL: CKAN_SMTP_USER is not configured" && ERROR=1)
([ ! -z "$CKAN_SMTP_PASSWORD" ] && export CKAN_SMTP_PASSWORD=$CKAN_SMTP_PASSWORD) || (echo "FATAL: CKAN_SMTP_PASSWORD is not configured" && ERROR=1)
([ ! -z "$CKAN_SMTP_ERROR_MAIL_TO" ] && export CKAN_SMTP_ERROR_MAIL_TO=$CKAN_SMTP_MAIL_TO) || (echo "WARNING: CKAN_SMTP_ERROR_MAIL_TO is not configured, error emails will not be sent.")
([ ! -z "$CKAN_SMTP_ERROR_MAIL_FROM" ] && export CKAN_SMTP_ERROR_MAIL_FROM=$CKAN_SMTP_MAIL_FROM) || (echo "WARNING: CKAN_SMTP_ERROR_MAIL_FROM is not configured, error emails will not be sent.")

# ERROR
# if any configuration errors have occured, we will need to exit

if [ $ERROR -eq 1 ]; then
  echo "Configuration errors above must be corrected before this container can start."
  echo "Ensure all required environment variables are set properly."
  echo "$@" >&2
  exit 1
else
  echo "Environment properly configured, moving on..."
fi

function waitfor() {
  echo checking connection to ${1}:${2};
  while ! nc -z $1 $2;
  do
    echo waiting for ${1}:${2};
    sleep 3;
  done;
  echo Connected to ${1}:${2};
}

waitfor $POSTGRES_FQDN $POSTGRES_PORT
waitfor $SOLR_FQDN $SOLR_PORT
waitfor $REDIS_FQDN $REDIS_PORT
waitfor $DATAPUSHER_FQDN $DATAPUSHER_PORT

# create the datastore_user if it does not exist
read rolname <<< `psql -X "$CKAN_SQLALCHEMY_URL" --single-transaction --set ON_ERROR_STOP=1 --no-align -t --field-separator ' ' --quiet -c "SELECT rolname FROM pg_catalog.pg_roles WHERE rolname = '$DATASTORE_ROLENAME'"`
if [ "${rolname}" != "${DATASTORE_ROLENAME}" ]; then
  echo "Creating the '$DATASTORE_ROLENAME' role"
  psql "$CKAN_SQLALCHEMY_URL" -c "CREATE ROLE ${DATASTORE_ROLENAME} NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '${POSTGRES_PASSWORD}'" > /dev/null 2>&1
  echo "The '$DATASTORE_ROLENAME' role was created."
else
  echo "The '$DATASTORE_ROLENAME' role already exists"
fi

# create the datastore database if it does not exists
read datname <<< `psql -X "$CKAN_SQLALCHEMY_URL" --single-transaction --set ON_ERROR_STOP=1 --no-align -t --field-separator ' ' --quiet -c "SELECT datname FROM pg_catalog.pg_database WHERE datname = '$DATASTORE_DB'"`
if [ "${datname}" != "${DATASTORE_DB}" ]; then
  echo "Creating the '$DATASTORE_DB' database catalog"
  psql "$CKAN_SQLALCHEMY_URL" -c "CREATE DATABASE ${DATASTORE_DB} OWNER ${POSTGRES_USER} ENCODING 'utf-8'" > /dev/null 2>&1
  psql "$CKAN_SQLALCHEMY_URL" -c "GRANT ALL PRIVILEGES ON DATABASE ${DATASTORE_DB} TO ${POSTGRES_USER}" > /dev/null 2>&1
  echo "The '$DATASTORE_DB' database catalog has been created."
else
  echo "The '$DATASTORE_DB' database already exists"
fi

echo "Running: envsubst"
CKAN_INI_UNCONFIGURED="${CKAN_INI}.unconfigured"
envsubst < $CKAN_INI_UNCONFIGURED > $CKAN_INI

echo "Running: db init"
ckan db init > /dev/null
echo "The 'db init' has completed"

echo "Running: datastore set-permissions"
ckan datastore set-permissions | psql "$CKAN_DATASTORE_WRITE_URL" --set ON_ERROR_STOP=1 > /dev/null
echo "The 'datastore set-permissions' has completed"

echo "Runing: exec"
exec "$@"
