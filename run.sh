#!/bin/bash -xe
docker-compose build --pull

FOLDER=`basename $PWD`
ACCOUNT_ID=`aws sts get-caller-identity | jq -r .Account`

echo "Logging In..." && `aws ecr get-login --no-include-email --region us-east-1`

docker tag "${FOLDER}_ckan" ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/ckan:latest
docker tag "${FOLDER}_solr" ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/ckan-solr:latest

docker push ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/ckan:latest
docker push ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/ckan-solr:latest
