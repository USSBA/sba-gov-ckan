#!/bin/bash -e
## configuring ckan
## https://docs.ckan.org/en/ckan-2.7.3/maintaining/configuration.html
## https://docs.ckan.org/en/2.8/maintaining/getting-started.html#create-admin-user

export POSTGRES_USER=${POSTGRES_USER:-ckan_default}
export POSTGRES_DB=${POSTGRES_DB:-ckan_default}
export SITE_ID=${SITE_ID:-default}

CONFIG_ERR=0

## configure the postgres databae host name
if [ -z "$POSTGRES_HOST" ]; then
  echo "FATAL: POSTGRES_HOST not configured"
  CONFIG_ERR=1
else
  export POSTGRES_HOST=${POSTGRES_HOST}
fi

## configure the ckan site sname
## ex: https://hostname:port
## note: omit a trailing slash
## note: this is required for interal redirection and must match the domain name exactly
if [ -z "$SITE_URL" ]; then
  echo "FATAL: SITE_URL not configured"
  CONFIG_ERR=1
else
  export SITE_URL=${SITE_URL}
fi

## configure the redis endpoint url including the database id
## ex: redis://redis-host:port/1
if [ -z "$REDIS_URL" ]; then
  echo "FATAL: REDIS_URL not configured"
  CONFIG_ERR=1
else
  export REDIS_URL=${REDIS_URL}
fi

## configure solr url/solr core endpoint url
## ex: http://solr-host:port/solr/ckan
if [ -z "$SOLR_URL" ]; then
  echo "FATAL: SOLR_URL not configured"
  CONFIG_ERR=1
else
  export SOLR_URL=${SOLR_URL}
fi

## configure password for the database
if [ -z "$POSTGRES_PASSWORD" ] && [ -z "$POSTGRES_PASSWORD_PSID" ]; then
  echo "FATAL: POSTGRES_PASSWORD or POSTGRES_PASSWORD_PSID not configured"
  CONFIG_ERR=1
else
  if [ ! -z "$POSTGRES_PASSWORD" ]; then
    export POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
  else
    export POSTGRES_PASSWORD=`aws ssm get-parameter --name ${POSTGRES_PASSWORD_PSID} | jq -r .Parameter.Value` || CONFIG_ERR=1
  fi
fi

## configure the smtp user name
if [ -z "$SMTP_USR" ] && [ -z "$SMTP_USR_SMID" ]; then
  echo "FATAL: SMTP_USR or SMTP_USR_SMID not configured"
  CONFIG_ERR=1
else
  if [ ! -z "$SMTP_USR" ]; then
    export SMTP_USR=${SMTP_USR}
  else
    export SMTP_USR=`aws secretsmanager get-secret-value --secret-id ${SMTP_USR_SMID} | jq -r .SecretString` || CONFIG_ERR=1
  fi
fi

## configure smtp user password
if [ -z "$SMTP_PWD" ] && [ -z "$SMTP_PWD_SMID" ]; then
  echo "FATAL: SMTP_PWD or SMTP_PWD_SMID not configured"
  CONFIG_ERR=1
else
  if [ ! -z "$SMTP_PWD" ]; then
    export SMTP_PWD=${SMTP_PWD}
  else
    export SMTP_PWD=`aws secretsmanager get-secret-value --secret-id ${SMTP_PWD_SMID} | jq -r .SecretString` || CONFIG_ERR=1
  fi
fi

## if an error was recorded, exit now
if [ "$CONFIG_ERR" == "1" ]; then
  echo "Configuration errors above must be corrected before this container can start.  Ensure all environment variables are set properly."
  echo "$@" >&2
  exit 1
fi

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

# TODO: we should not initialize the database on every container that starts
# perhasp we can use Cloud9 as a management console for CKAN
ckan-paster --plugin=ckan db init -c "$CONFIG"

# TODO: we may need to only run this line if the user does not exist...
# running subsequent times no updates to the user will occur meaning the password/email will not
# change once the user is created; that will need to be done via browser
# perhasp we can use Cloud9 as a management console for CKAN
yes | ckan-paster --plugin=ckan sysadmin add ias email=sbaias@fearless.tech password=${POSTGRES_PASSWORD} --config "$CONFIG"

# DATASTORE/DATAPUSHER STUFF
# ckan-paster --plugin=ckan datastore set-permissions -c "${CKAN_CONFIG}/production.ini" | \
#   psql -a "${CKAN_SQLALCHEMY_URL}" --set ON_ERROR_STOP=1

exec "$@"
