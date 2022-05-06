# Terraform Base

## Workspaces

- `staging`
- `production`

## Modules

### `ckan`

All the services to support data.sba.gov's CKAN implementation.

- Staging/Production environments

## ECS Guide

You can now exec into a running Fargate container with the latest version of AWSCLI.

### Connect to running Fargate container

```
# Configure AWS Credentials, then run...

$ ./service-list.sh
```

### `backup`

Resources to support backing up SBA.gov services

- SBA.gov EFS
  - staging/production
- SBA.gov DynamoDB
  - UrlToNode staging/production
  - UrlToUrlRedirect staging/production

At this time, AWS Backups does not support Aurora RDS, so backups are managed natively within Aurora, plus an external db-dump service
