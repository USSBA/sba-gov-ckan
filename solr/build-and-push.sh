if [ ! -z "${AWS_PROFILE}" ]; then
  IMAGE=ckan-solr
  ACCOUNT_ID=`aws sts get-caller-identity | jq -r .Account`

  docker image build -t ${IMAGE} .

  echo "Logging In..." && `aws ecr get-login --no-include-email --region us-east-1`
  docker tag ckan-solr:latest ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE}:latest
  docker push ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE}:latest
fi
