#!/bin/sh -xe

abort () {
  echo "$@" >&2
  exit 1
}

# Configuring CKAN
# https://docs.ckan.org/en/ckan-2.7.3/maintaining/configuration.html

if [ -z "$POSTGRES_USER" ]; then
  abort
fi
if [ -z "$POSTGRES_HOST" ]; then
  abort
fi
if [ -z "$POSTGRES_DB" ]; then
  abort
fi
if [ -z "$SITE_URL" ]; then
  abort
fi
if [ -z "$REDIS_URL" ]; then
  abort
fi
if [ -z "$SOLR_URL" ]; then
  abort
fi

export POSTGRES_USER=${POSTGRES_USER}
export POSTGRES_PASSWORD=`aws ssm get-parameter --name ${POSTGRES_PWD_PARAMETER} | jq -r .Parameter.Value`
export POSTGRES_HOST=${POSTGRES_HOST}
export POSTGRES_DB=${POSTGRES_DB}
export SITE_ID=${SITE_ID:-default}
export SITE_URL=${SITE_URL}
export REDIS_URL=${REDIS_URL}
export SOLR_URL=${SOLR_URL}
export SMTP_USR=`aws secretsmanager get-secret-value --secret-id ${SMTP_USR_PARAMETER_ID} | jq -r .SecretString`
export SMTP_PWD=`aws secretsmanager get-secret-value --secret-id ${SMTP_PWD_PARAMETER_ID} | jq -r .SecretString`

# DATASTORE/DATAPUSHER STUFF
# until psql "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db/${POSTGRES_DB}" -c '\q'; do
#   >&2 echo "Postgres is unavailable - sleeping"
#   sleep 1
# done
# DB_RESULT=`psql -t -l "${CKAN_SQLALCHEMY_URL}" | cut -d'|' -f1 | grep -oh "${POSTGRES_DATASTORE_DB}" || :`
# if [ "$DB_RESULT" != "${POSTGRES_DATASTORE_DB}" ]; then
#   echo "Creating Database for CKAN datastore extension"
#   #psql -e "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db/${POSTGRES_DB}" <<-EOSQL
#   psql -a "${CKAN_SQLALCHEMY_URL}" <<-EOSQL
#     CREATE ROLE ${POSTGRES_DATASTORE_USER} NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '$POSTGRES_PASSWORD';
#     CREATE DATABASE ${POSTGRES_DATASTORE_DB} OWNER ${POSTGRES_USER} ENCODING 'utf-8';
#     -- GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DATASTORE_DB} TO ${POSTGRES_USER};
#     -- CREATE EXTENSION POSTGIS;
#     -- ALTER VIEW geometry_columns OWNER TO ${POSTGRES_USER};
#     -- ALTER TABLE spatial_ref_sys OWNER TO ${POSTGRES_USER};
# EOSQL
# fi

CONFIG="${CKAN_CONFIG}/production.ini"
envsubst < $CONFIG > $CONFIG

#THIS WILL CREATE A CONFIG EVERYTIME THE CONTAINER STARTS
# - WE NOW INJECT THIS FILE AS A TEMPLATE DURING DOCKER IMAGE BUILD
#ckan-paster make-config -v -q ckan "$CONFIG"

# JUST IN-CASE
#grep -n 'ckan.auth.create_user_via_api' $CONFIG | cut -d: -f1 | sed -i "$(xargs)s/true/false/" $CONFIG
#grep -n 'ckan.auth.create_user_via_web' $CONFIG | cut -d: -f1 | sed -i "$(xargs)s/true/false/" $CONFIG

ckan-paster --plugin=ckan db init -c "$CONFIG"

# https://docs.ckan.org/en/2.8/maintaining/getting-started.html#create-admin-user
yes | ckan-paster --plugin=ckan sysadmin add ias email=sbaias@fearless.tech password=${POSTGRES_PASSWORD} --config "$CONFIG"

# DATASTORE/DATAPUSHER STUFF
# ckan-paster --plugin=ckan datastore set-permissions -c "${CKAN_CONFIG}/production.ini" | \
#   psql -a "${CKAN_SQLALCHEMY_URL}" --set ON_ERROR_STOP=1

exec "$@"
