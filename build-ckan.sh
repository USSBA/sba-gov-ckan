#!/bin/bash -xe
if [ -d "../ckan" ] && [ -d "../ckan/.git" ]; then
  cd ../ckan/contrib/docker
else
  cd ..
  git clone https://github.com/ckan/ckan.git
  cd ckan/contrib/docker
fi

cp .env.template .env
docker-compose build --pull ckan
rm .env

if [ ! -z "${AWS_PROFILE}" ]; then
  IMAGE=ckan
  ACCOUNT_ID=`aws sts get-caller-identity | jq -r .Account`

  echo "Logging In..." && `aws ecr get-login --no-include-email --region us-east-1`
  docker tag docker_ckan:latest ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE}:latest
  docker push ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE}:latest
fi

