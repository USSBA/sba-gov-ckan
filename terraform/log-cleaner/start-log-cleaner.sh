#!/bin/bash

aws ecs run-task \
  --cluster ckan-staging \
  --task-definition `aws ecs describe-task-definition --task-definition staging-log-cleaner --query "taskDefinition.taskDefinitionArn" --output text` \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-08e14aa19eb632f5f],securityGroups=[sg-0d7c334e631313837],assignPublicIp='DISABLED'}"
