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

## configure the ckan sites name
## ex: https://hostname:port
## note: omit a trailing slash
## note: this is required for internal redirection and must match the domain name exactly
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

## configure session secret
if [ -z "$SESSION_SECRET" ] && [ -z "$SESSION_SECRET_PSID" ]; then
  echo "FATAL: SESSION_SECRET or SESSION_SECRET_PSID not configured"
  CONFIG_ERR=1
else
  if [ ! -z "$SESSION_SECRET" ]; then
    export SESSION_SECRET=${SESSION_SECRET}
  else
    export SESSION_SECRET=`aws ssm get-parameter --name ${SESSION_SECRET_PSID} | jq -r .Parameter.Value` || CONFIG_ERR=1
  fi
fi

## configure unique id
if [ -z "$APP_UUID" ] && [ -z "$APP_UUID_PSID" ]; then
  echo "FATAL: APP_UUID or APP_UUID_PSID not configured"
  CONFIG_ERR=1
else
  if [ ! -z "$APP_UUID" ]; then
    export APP_UUID=${APP_UUID}
  else
    export APP_UUID=`aws ssm get-parameter --name ${APP_UUID_PSID} | jq -r .Parameter.Value` || CONFIG_ERR=1
  fi
fi

## if an error was recorded, exit now
if [ "$CONFIG_ERR" == "1" ]; then
  echo "Configuration errors above must be corrected before this container can start.  Ensure all environment variables are set properly."
  echo "$@" >&2
  exit 1
else
  echo "All environment variables are properly set."
fi



function waitfor() {
  while ! nc -z $1 $2;
  do
    echo waiting for ${1}:${2};
    sleep 3;
  done;
  echo Connected to ${1}:${2};
}

waitfor $POSTGRES_HOST 5432
waitfor $SOLR_HOST 8983
waitfor $REDIS_HOST 6379
waitfor $DATAPUSHER_HOST 8800

# TODO: Improve initialization workflow
# if (database not configured):
#   db init
#   db migrate?
#   sysadmin add admin account
# else:
#   do nothing

# create the datastore_user if it does not exist
export DATASTORE_ROLENAME=datastore_default
read rolname <<< `psql -X "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}/${POSTGRES_DB}" --single-transaction --set ON_ERROR_STOP=1 --no-align -t --field-separator ' ' --quiet -c "SELECT rolname FROM pg_catalog.pg_roles WHERE rolname = '$DATASTORE_ROLENAME'"`
if [ "${rolname}" != "${DATASTORE_ROLENAME}" ]; then
  echo "Creating the '$DATASTORE_ROLENAME' role"
  psql "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}/${POSTGRES_DB}" -c "CREATE ROLE ${DATASTORE_ROLENAME} NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '${POSTGRES_PASSWORD}'"
else
  echo "The '$DATASTORE_ROLENAME' role already exists"
fi

# create the datastore database if it does not exists
export DATASTORE_DB=datastore_default
read datname <<< `psql -X "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}/${POSTGRES_DB}" --single-transaction --set ON_ERROR_STOP=1 --no-align -t --field-separator ' ' --quiet -c "SELECT datname FROM pg_catalog.pg_database WHERE datname = '$DATASTORE_DB'"`
if [ "${datname}" != "${DATASTORE_DB}" ]; then
  echo "Creating the '$DATASTORE_DB' database catalog"
  psql "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}/${POSTGRES_DB}" -c "CREATE DATABASE ${DATASTORE_DB} OWNER ${POSTGRES_USER} ENCODING 'utf-8'"
  psql "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}/${POSTGRES_DB}" -c "GRANT ALL PRIVILEGES ON DATABASE ${DATASTORE_DB} TO ${POSTGRES_USER}"
else
  echo "The '$DATASTORE_DB' role already exists"
fi

echo "Running: envsubst"
CONFIG="${CKAN_CONFIG}/production.ini"
UNCONFIGURED_CONFIG="${CONFIG}.unconfigured"
envsubst < $UNCONFIGURED_CONFIG > $CONFIG

echo "Running: db init"
ckan-paster --plugin=ckan db init -c "$CONFIG"

echo "Running: datastore set-permissions"
ckan-paster --plugin=ckan datastore set-permissions -c ${CONFIG} | psql "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}/${DATASTORE_DB}" --set ON_ERROR_STOP=1

# TODO: we may need to only run this line if the user does not exist...
# running subsequent times no updates to the user will occur meaning the password/email will not
# change once the user is created; that will need to be done via browser
# perhasp we can use Cloud9 as a management console for CKAN
echo "Running: sysadmin add"
yes | ckan-paster --plugin=ckan sysadmin add ias email=sbaias@fearless.tech password=${POSTGRES_PASSWORD} --config "$CONFIG"

# DATASTORE/DATAPUSHER STUFF
# ckan-paster --plugin=ckan datastore set-permissions -c "${CKAN_CONFIG}/production.ini" | \
#   psql -a "${CKAN_SQLALCHEMY_URL}" --set ON_ERROR_STOP=1
echo "Runing: exec"
exec "$@"
