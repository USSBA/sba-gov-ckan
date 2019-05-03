PWD=`aws ssm get-parameter --name /ckan/staging/db_password/postgres | jq -r .Parameter.Value`
echo "POSTRES_PASSWORD=$PWD" > .env
