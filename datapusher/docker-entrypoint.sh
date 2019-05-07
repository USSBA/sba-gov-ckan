export POSTGRES_DB=${POSTGRES_DB}
export POSTGRES_HOST=${POSTGRES_HOST}
export POSTGRES_USER=${POSTGRES_USER}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

CONFIG="/usr/src/app/deployment/datapusher_settings.py"

#sed -i "s/POSTGRES_DB/db/" $CONFIG
#sed -i "s/POSTGRES_HOST/host/" $CONFIG
#sed -i "s/POSTGRES_USER/user/" $CONFIG
#sed -i "s/POSTGRES_PASSWORD/password/" $CONFIG


exec "$@"
