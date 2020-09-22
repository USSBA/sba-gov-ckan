#!/bin/bash -e
docker-compose build --pull ${1}

if [[ "${2:-none}" == "push" ]]; then
  ACCOUNT_ID=`aws sts get-caller-identity | jq -r .Account`
  echo "Loggin into ECR"
  aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
  docker tag $1 ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/$1:dev
  docker push ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/$1:dev
else
  echo "Second parameter was not 'push', to push the image to ECR please enter '$0 $1 push'"
fi
